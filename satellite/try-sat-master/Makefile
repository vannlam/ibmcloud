SHELL := /bin/bash
LANG := en-US.UTF-8

ifndef RESOURCE_PREFIX
$(error RESOURCE_PREFIX is not set, please read the README and set using .envrc.)
endif

ifndef IC_API_KEY
$(error IC_API_KEY is not set, please read the README and set using .envrc.)
endif

.PHONY: all

install:
	# Unfortunately the ibmcloud CLI does not give an appropriate RC when
	# ibmcloud plugin update fails, so it's not easy to automate this
	# elegantly. You may get duplicate messages as plugins are both
	# installed and updated.
	ibmcloud plugin install container-registry
	ibmcloud plugin install container-service
	ibmcloud plugin install observe-service
	ibmcloud plugin install vpc-infrastructure
	ibmcloud plugin update container-registry
	ibmcloud plugin update container-service
	ibmcloud plugin update observe-service
	ibmcloud plugin update vpc-infrastructure

watch:
	./watch_ibmcloud

terraform_init:
ifeq (, $(shell which tfswitch))
	(cd terraform && terraform init -upgrade)
else
	(cd terraform && tfswitch && terraform init -upgrade)
endif

clean: terraform_init ssh-keys/ssh-key login_ibmcloud
	@echo "Clean is starting in 5 seconds, Ctrl-C if you don't want to proceed..."
	@sleep 5
	rm -fv wireguard-$(RESOURCE_PREFIX).conf
	rm -fv terraform/.onboarding_script_*
	rm -fv terraform/onboarding_script_*
	while ibmcloud oc cluster get --cluster $(RESOURCE_PREFIX)-cluster 2>/dev/null >/dev/null; do ibmcloud oc cluster rm -f --cluster $(RESOURCE_PREFIX)-cluster; echo 'Waiting for cluster to be deleted...'; sleep 30; done
	-cd terraform && terraform destroy -auto-approve && rm -fv terraform.tfstate*
	rm -fv ssh-keys/ssh-key
	rm -fv ssh-keys/ssh-key.pub

ssh-keys/ssh-key:
	mkdir -p ssh-keys/
	ssh-keygen -f ssh-keys/ssh-key -N ''

login_ibmcloud:
	ibmcloud login --apikey $(IC_API_KEY) -r $(LOCATION_REGION)

login_ibmcloud_silent:
	make login_ibmcloud 2>&1 >/dev/null

target: terraform_init login_ibmcloud
	(cd terraform && terraform apply -target=ibm_resource_group.group -auto-approve)
	ibmcloud target -g $(RESOURCE_PREFIX)-group -r $(LOCATION_REGION)

apply_terraform_location: terraform_init
	(cd terraform && terraform apply -target=ibm_satellite_location.location -auto-approve)

apply_terraform: apply_terraform_location terraform_init terraform/onboarding_script_controlplane01.sh ssh-keys/ssh-key
	(cd terraform && terraform apply -auto-approve)

terraform/onboarding_script_controlplane01.sh:
	until ibmcloud sat host attach --location $(RESOURCE_PREFIX)-location --host-label name=controlplane01 -q > terraform/.onboarding_script_controlplane01_name; do sleep 30; done
	until ibmcloud sat host attach --location $(RESOURCE_PREFIX)-location --host-label name=controlplane02 -q > terraform/.onboarding_script_controlplane02_name; do sleep 30; done
	until ibmcloud sat host attach --location $(RESOURCE_PREFIX)-location --host-label name=controlplane03 -q > terraform/.onboarding_script_controlplane03_name; do sleep 30; done
	until ibmcloud sat host attach --location $(RESOURCE_PREFIX)-location --host-label name=workernode01 -q > terraform/.onboarding_script_workernode01_name; do sleep 30; done
	until ibmcloud sat host attach --location $(RESOURCE_PREFIX)-location --host-label name=workernode02 -q > terraform/.onboarding_script_workernode02_name; do sleep 30; done
	until ibmcloud sat host attach --location $(RESOURCE_PREFIX)-location --host-label name=workernode03 -q > terraform/.onboarding_script_workernode03_name; do sleep 30; done
	cat `cat terraform/.onboarding_script_controlplane01_name` > terraform/onboarding_script_controlplane01.sh
	cat `cat terraform/.onboarding_script_controlplane02_name` > terraform/onboarding_script_controlplane02.sh
	cat `cat terraform/.onboarding_script_controlplane03_name` > terraform/onboarding_script_controlplane03.sh
	cat `cat terraform/.onboarding_script_workernode01_name` > terraform/onboarding_script_workernode01.sh
	cat `cat terraform/.onboarding_script_workernode02_name` > terraform/onboarding_script_workernode02.sh
	cat `cat terraform/.onboarding_script_workernode03_name` > terraform/onboarding_script_workernode03.sh

attach_host_ready:
	until [ $$(ibmcloud sat host ls --location $(RESOURCE_PREFIX)-location | grep Ready | grep unassigned | wc -l) -gt 5 ]; do echo 'Waiting for 6 hosts to be attached...'; sleep 30; make login_ibmcloud_silent; done

setup_dns_controlplane:
	# For more information, see http://ibm.biz/satloc-ts-subdomain
	until ibmcloud sat location dns register --ip $(shell cd terraform && terraform output -raw ipaddress_controlplane01_floating) --ip $(shell cd terraform && terraform output -raw ipaddress_controlplane02_floating) --ip $(shell cd terraform && terraform output -raw ipaddress_controlplane03_floating) --location $(RESOURCE_PREFIX)-location; do echo 'Waiting to set up control plane DNS...'; sleep 30; make login_ibmcloud_silent; done

dns_controlplane_ready:
	until ibmcloud sat location dns ls --location $(RESOURCE_PREFIX)-location | grep $(shell cd terraform && terraform output -raw ipaddress_controlplane01_floating); do echo 'Waiting for control plane DNS records to be registered...'; sleep 30; make login_ibmcloud_silent; done

assign_controlplane:
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --zone=location-zone-1 --host=$(RESOURCE_PREFIX)-controlplane01; do echo 'Waiting to assign host to control plane'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --zone=location-zone-2 --host=$(RESOURCE_PREFIX)-controlplane02; do echo 'Waiting to assign host to control plane'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --zone=location-zone-3 --host=$(RESOURCE_PREFIX)-controlplane03; do echo 'Waiting to assign host to control plane'; sleep 30; done

assign_controlplane_ready:
	until ibmcloud sat location get --location $(RESOURCE_PREFIX)-location | grep -E 'Message|Mensaje' | grep R0001; do echo 'Waiting for control plane to be assigned and location to be ready.'; sleep 60; make login_ibmcloud_silent; done

create_cluster: target
	$(eval DEFAULT_MAJOR_VERSION=$(shell ibmcloud ks versions --json | jq '.openshift[] | select(.default == true) | .major'))
	$(eval DEFAULT_MINOR_VERSION=$(shell ibmcloud ks versions --json | jq '.openshift[] | select(.default == true) | .minor'))
	until ibmcloud oc cluster create satellite --location $(RESOURCE_PREFIX)-location --name $(RESOURCE_PREFIX)-cluster --version $(DEFAULT_MAJOR_VERSION).$(DEFAULT_MINOR_VERSION)_openshift --enable-config-admin; do echo 'Waiting to create cluster...'; sleep 30; make login_ibmcloud_silent; done

cluster_in_warning:
	# Cluster is ready once it moves to "warning" state (the warning is because it will have no worker nodes yet).
	until ibmcloud oc cluster get --cluster $(RESOURCE_PREFIX)-cluster 2>/dev/null | grep 'State.*warning' >/dev/null; do echo 'Waiting on cluster to move to "warning" status...'; sleep 30; make login_ibmcloud_silent; done

cluster_in_normal:
	until ibmcloud oc cluster get --cluster $(RESOURCE_PREFIX)-cluster 2>/dev/null | grep 'State.*normal' >/dev/null; do echo 'Waiting on cluster to move to "normal" status...'; sleep 30; make login_ibmcloud_silent; done

assign_workernodes:
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --worker-pool=default --host=$(RESOURCE_PREFIX)-workernode01 --cluster $(RESOURCE_PREFIX)-cluster; do echo 'Waiting to assign worker nodes...'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --worker-pool=default --host=$(RESOURCE_PREFIX)-workernode02 --cluster $(RESOURCE_PREFIX)-cluster; do echo 'Waiting to assign worker nodes...'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --worker-pool=default --host=$(RESOURCE_PREFIX)-workernode03 --cluster $(RESOURCE_PREFIX)-cluster; do echo 'Waiting to assign worker nodes...'; sleep 30; done

login_cluster: get_cluster_config
	oc login -u apikey -p $(IC_API_KEY)

setup_network_cluster:
	$(eval NLB_HOST=$(shell ibmcloud ks nlb-dns ls --cluster $(RESOURCE_PREFIX)-cluster | tail -1 | cut -f1 -d' '))
	$(eval NLB_IP=$(shell ibmcloud ks nlb-dns ls --cluster $(RESOURCE_PREFIX)-cluster | tail -1 | cut -d' ' -f4))
	scripts/nlb-dns-remove $(NLB_IP) $(NLB_HOST) $(RESOURCE_PREFIX)
	until ibmcloud ks nlb-dns add --cluster $(RESOURCE_PREFIX)-cluster --nlb-host $(NLB_HOST) --ip $(shell cd terraform && terraform output -raw ipaddress_workernode01_floating) --ip $(shell cd terraform && terraform output -raw ipaddress_workernode02_floating) --ip $(shell cd terraform && terraform output -raw ipaddress_workernode03_floating); do echo 'Waiting to add NLB IPs...'; sleep 30; done

network_cluster_ready:
	until ibmcloud ks nlb-dns ls --cluster $(RESOURCE_PREFIX)-cluster | grep $(shell cd terraform && terraform output -raw ipaddress_workernode01_floating); do echo 'Waiting for cluster DNS records to be registered...'; sleep 30; make login_ibmcloud_silent; done

get_cluster_config: login_ibmcloud
	ibmcloud oc cluster config --cluster $(RESOURCE_PREFIX)-cluster --admin

configure_cluster_logdna: get_cluster_config
	oc delete secret logdna-agent-key || true
	oc create secret generic logdna-agent-key --from-literal=logdna-agent-key=$(shell cd terraform && terraform output -raw logdna_ingestion_key)
	oc apply -f https://assets.eu-gb.logging.cloud.ibm.com/clients/logdna-agent-ds.yaml

wireguard-$(RESOURCE_PREFIX).conf: ssh-keys/ssh-key apply_terraform
	# There is no point in having strict host key checking, as floating IPs may get reused and we'll only connect to this server once.
	scp -o StrictHostKeyChecking=no -i ssh-keys/ssh-key root@$(shell cd terraform && terraform output -raw ipaddress_wireguard_floating):wireguard.client wireguard-$(RESOURCE_PREFIX).conf

get_wireguard_config: wireguard-$(RESOURCE_PREFIX).conf

deploy_sample_app: get_cluster_config
	oc new-app docker.io/nginxdemos/hello
	oc expose service hello
	until [ $$(oc get route --output=name | wc -l) -gt 0 ]; do echo 'Waiting for OpenShift route...'; sleep 5; done
	@echo "You can open the sample app in your browser at http://$(shell oc get route -o jsonpath='{..spec.host}{"\n"}')"

create_sat_link_endpoint: login_ibmcloud
	$(eval SAT_ID=$(shell ibmcloud sat location get --location $(RESOURCE_PREFIX)-location | grep ID | sed -E 's/ID:\s*//'))
	ibmcloud sat endpoint create --dest-hostname $(shell cd terraform && terraform output -raw ipaddress_onprem_private) --dest-port 80 --dest-type location --location $(SAT_ID) --name Hello-On-Prem-HTTP --source-protocol HTTP
	until ibmcloud sat endpoint ls --location $(SAT_ID) | grep Hello-On-Prem-HTTP ; do echo 'Waiting to satellite link endpoint...'; sleep 30; done
	make print_sat_link_hostname

print_sat_link_hostname:
	$(eval SAT_ID=$(shell ibmcloud sat location get --location $(RESOURCE_PREFIX)-location | grep ID | sed -E 's/ID:\s*//'))
	$(eval END_ID=$(shell ibmcloud sat endpoint ls --location $(SAT_ID) | grep Hello-On-Prem-HTTP  | grep -Eo '((^[A-Za-z0-9_]+\s))' ))
	$(eval END_HOSTNAME=$(shell ibmcloud sat endpoint get --endpoint $(END_ID) --location $(SAT_ID) | grep Address | grep -Eo '(([A-Za-z0-9\-]+\.){7}(com:[0-9]{2,5}))'))
	@echo "You can reach the on-prem resource at http://$(shell ibmcloud sat endpoint get --location $(SAT_ID) --endpoint $(shell ibmcloud sat endpoint ls --location $(SAT_ID) | grep Hello-On-Prem-HTTP | grep -Eo '((^[A-Za-z0-9_]+\s))') | grep Address | grep -Eo '(([A-Za-z0-9\-]+\.){7}(com:[0-9]{2,5}))')/health"

all_private_location: login_ibmcloud
	TF_VAR_CREATE_FLOATING_IP=0 make apply_terraform
	make get_wireguard_config
	make attach_host_ready
	make assign_controlplane
	make assign_controlplane_ready

all_private_cluster: login_ibmcloud
	make create_cluster
	make cluster_in_warning
	make assign_workernodes
	make cluster_in_normal

all_private:
	make all_private_location
	make all_private_cluster
	@echo "Done!"

all_public_location: login_ibmcloud
	TF_VAR_CREATE_FLOATING_IP=1 make apply_terraform
	make attach_host_ready
	make assign_controlplane
	make assign_controlplane_ready
	make setup_dns_controlplane
	make dns_controlplane_ready

all_public_cluster: login_ibmcloud
	make create_cluster
	make cluster_in_warning
	make assign_workernodes
	make cluster_in_normal
	make setup_network_cluster
	make network_cluster_ready
	make configure_cluster_logdna

all_public:
	make all_public_location
	make all_public_cluster
	@echo "Done!"
