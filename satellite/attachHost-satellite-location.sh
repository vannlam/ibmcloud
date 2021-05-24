#!/usr/bin/env bash
cat << 'HERE' >>/usr/local/bin/ibm-host-attach.sh
#!/usr/bin/env bash
set -ex
mkdir -p /etc/satelliteflags
HOST_ASSIGN_FLAG="/etc/satelliteflags/hostattachflag"
if [[ -f "$HOST_ASSIGN_FLAG" ]]; then
  echo "host has already been assigned. need to reload before you try the attach again"
  exit 0
fi
set +x
HOST_QUEUE_TOKEN="ce43612a6d88d9a93493324ac488b8361be2e2be2f1d59db6f100dce5ad86dc5d79b4a334340788676a926a08ba2a4f738025ffb16d91a3ce69aca897ca3e9d7e5ed111f791162ff9ac60f9a81604b4a4db2666c802ee5061289e1ad1ba42efbf00e507d8f599b646856e69f4eed57b78d637d0261cdd597dcde4659ac0fb89c2cc714e70f5b48f5c684b787c767c9a3931802ecf04eb126636d7141f82d4d42523f4c589990a38e5c3529f11e3cabbc7c2455f9330de5da9c9e7e72ec6aa662e47f6eb1adfe45430f93b31fc6b6bc4388b71faafdbb76332b5706ed12973316cba5f5f4153ebcf032281f30214c8486891227162934fe0bebac538d540c5fea"
set -x
ACCOUNT_ID="c828fd5b0ac169054274cc28669467bf"
CONTROLLER_ID="c28q30nl010q2k4cat3g"
SELECTOR_LABELS='{}'
API_URL="https://origin.eu-gb.containers.cloud.ibm.com/"

subscription-manager refresh
subscription-manager repos --enable=*

#shutdown known blacklisted services for Satellite (these will break kube)
set +e
systemctl stop -f iptables.service
systemctl disable iptables.service
systemctl mask iptables.service
systemctl stop -f firewalld.service
systemctl disable firewalld.service
systemctl mask firewalld.service
set -e

# ensure you can successfully communicate with redhat mirrors (this is a prereq to the rest of the automation working)
yum install rh-python36 -y
mkdir -p /etc/satellitemachineidgeneration
if [[ ! -f /etc/satellitemachineidgeneration/machineidgenerated ]]; then
  rm -f /etc/machine-id
  systemd-machine-id-setup
  touch /etc/satellitemachineidgeneration/machineidgenerated
fi
#STEP 1: GATHER INFORMATION THAT WILL BE USED TO REGISTER THE HOST
HOSTNAME=$(hostname -s)
HOSTNAME=${HOSTNAME,,}
MACHINE_ID=$(cat /etc/machine-id )
CPUS=$(nproc)
MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')
export CPUS
export MEMORY
SELECTOR_LABELS=$(echo "${SELECTOR_LABELS}" | python -c "import sys, json, os; z = json.load(sys.stdin); y = {\"cpu\": os.getenv('CPUS'), \"memory\": os.getenv('MEMORY')}; z.update(y); print(json.dumps(z))")

#Step 2: SETUP METADATA
cat << EOF > register.json
{
"controller": "$CONTROLLER_ID",
"name": "$HOSTNAME",
"identifier": "$MACHINE_ID",
"labels": $SELECTOR_LABELS
}
EOF

set +x
#STEP 3: REGISTER HOST TO THE HOSTQUEUE. NEED TO EVALUATE HTTP STATUS 409 EXISTS, 201 created. ALL OTHERS FAIL.
HTTP_RESPONSE=$(curl --write-out "HTTPSTATUS:%{http_code}" --retry 100 --retry-delay 10 --retry-max-time 1800 -X POST \
  -H  "X-Auth-Hostqueue-APIKey: $HOST_QUEUE_TOKEN" \
  -H  "X-Auth-Hostqueue-Account: $ACCOUNT_ID" \
  -H "Content-Type: application/json" \
  -d @register.json \
  "${API_URL}v2/multishift/hostqueue/host/register")
set -x
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed -E 's/HTTPSTATUS\:[0-9]{3}$//')
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tr -d '\n' | sed -E 's/.*HTTPSTATUS:([0-9]{3})$/\1/')

echo "$HTTP_BODY"
echo "$HTTP_STATUS"
if [ "$HTTP_STATUS" -ne 201 ]; then
 echo "Error [HTTP status: $HTTP_STATUS]"
 exit 1
fi

HOST_ID=$(echo "$HTTP_BODY" | python -c "import sys, json; print(json.load(sys.stdin)['id'])")

#STEP 4: WAIT FOR MEMBERSHIP TO BE ASSIGNED
while true
do
  set +ex
  ASSIGNMENT=$(curl --retry 100 --retry-delay 10 --retry-max-time 1800 -G -X GET \
    -H  "X-Auth-Hostqueue-APIKey: $HOST_QUEUE_TOKEN" \
    -H  "X-Auth-Hostqueue-Account: $ACCOUNT_ID" \
    -d controllerID="$CONTROLLER_ID" \
    -d hostID="$HOST_ID" \
    "${API_URL}v2/multishift/hostqueue/host/getAssignment")
  set -ex
  isAssigned=$(echo "$ASSIGNMENT" | python -c "import sys, json; print(json.load(sys.stdin)['isAssigned'])" | awk '{print tolower($0)}')
  if [[ "$isAssigned" == "true" ]] ; then
    break
  fi
  if [[ "$isAssigned" != "false" ]]; then
    echo "unexpected value for assign retrying"
  fi
  sleep 10
done

#STEP 5: ASSIGNMENT HAS BEEN MADE. SAVE SCRIPT AND RUN
echo "$ASSIGNMENT" | python -c "import sys, json; print(json.load(sys.stdin)['script'])" > /usr/local/bin/ibm-host-agent.sh
export HOST_ID
ASSIGNMENT_ID=$(echo "$ASSIGNMENT" | python -c "import sys, json; print(json.load(sys.stdin)['id'])")
cat << EOF > /etc/satelliteflags/ibm-host-agent-vars
export HOST_ID=${HOST_ID}
export ASSIGNMENT_ID=${ASSIGNMENT_ID}
EOF
chmod 0600 /etc/satelliteflags/ibm-host-agent-vars
chmod 0700 /usr/local/bin/ibm-host-agent.sh
cat << EOF > /etc/systemd/system/ibm-host-agent.service
[Unit]
Description=IBM Host Agent Service
After=network.target

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/usr/local/bin/ibm-host-agent.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/ibm-host-agent.service
systemctl daemon-reload
systemctl start ibm-host-agent.service
touch "$HOST_ASSIGN_FLAG"
HERE

chmod 0700 /usr/local/bin/ibm-host-attach.sh
cat << 'EOF' >/etc/systemd/system/ibm-host-attach.service
[Unit]
Description=IBM Host Attach Service
After=network.target

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/usr/local/bin/ibm-host-attach.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
chmod 0644 /etc/systemd/system/ibm-host-attach.service
systemctl daemon-reload
systemctl enable ibm-host-attach.service
systemctl start ibm-host-attach.service
