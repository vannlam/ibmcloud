SHELL := /bin/bash

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

watch: login_ibmcloud
	./watch_ibmcloud

terraform_init: ssh-keys/ssh-key
ifeq (, $(shell which tfswitch))
	(cd terraform && terraform init)
else
	(cd terraform && tfswitch && terraform init)
endif

perform_clean: terraform_init login_ibmcloud
	while ibmcloud oc cluster get --cluster $(RESOURCE_PREFIX)-cluster 2>/dev/null >/dev/null; do ibmcloud oc cluster rm -f --cluster $(RESOURCE_PREFIX)-cluster; echo 'Waiting for cluster to be deleted...'; sleep 30; done
	while ibmcloud sat location ls | grep $(RESOURCE_PREFIX)-location; do ibmcloud sat location rm -f --location $(RESOURCE_PREFIX)-location; echo 'Waiting for location to be deleted...'; sleep 30; done
	cd terraform && terraform destroy -auto-approve

check_clean:
	@echo -n "Are you sure you want to delete all resources? [y/N] " && read ans && [ $${ans:-N} = y ]

aggressive_clean: check_clean
	until make perform_clean; do echo 'Retrying clean...'; sleep 30; done

clean: check_clean terraform_init
	make perform_clean

ssh-keys/ssh-key:
	mkdir -p ssh-keys/
	ssh-keygen -f ssh-keys/ssh-key -N ''

login_ibmcloud:
	# For now, we forcibly select us-east from this list: https://cloud.ibm.com/docs/satellite?topic=satellite-sat-regions.
	ibmcloud login --apikey $(IC_API_KEY) -r $(LOCATION_REGION)

target: terraform_init
	(cd terraform && terraform apply -target=ibm_resource_group.group -auto-approve)
	ibmcloud target -g $(RESOURCE_PREFIX)-group -r $(LOCATION_REGION)

create_location: target
	# Creation command does not return a reliable RC; sometimes succeeds but
	# still appears to have failed.
	#
	# Note: as far as I can tell, locations do not have a resource group, so
	# it doesn't matter that at this stage Terraform may not have been
	# applied and the resource group targeted.
	-ibmcloud sat location create --managed-from lon --name $(RESOURCE_PREFIX)-location

location_ready:
	until ibmcloud sat locations | grep $(RESOURCE_PREFIX)-location | grep 'action required'; do echo 'Waiting on location to be in status "action-required"...'; sleep 30; done

apply_terraform: terraform_init get_attach_scripts get_attach_scripts
	(cd terraform && terraform apply -auto-approve)

get_terraform_show:
	(cd terraform && terraform show -json > ../terraform_show.json)

get_attach_scripts: location_ready
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
	until [ $$(ibmcloud sat host ls --location $(RESOURCE_PREFIX)-location | grep Ready | grep unassigned | wc -l) -gt 5 ]; do echo 'Waiting for 6 hosts to be attached...'; sleep 30; done

setup_dns_controlplane:
	# For more information, see http://ibm.biz/satloc-ts-subdomain
	until ibmcloud sat location dns register --ip $(shell cat terraform_show.json | jq --raw-output .values.outputs.ipaddress_controlplane01_floating.value) --ip $(shell cat terraform_show.json | jq --raw-output .values.outputs.ipaddress_controlplane02_floating.value) --ip $(shell cat terraform_show.json | jq --raw-output .values.outputs.ipaddress_controlplane03_floating.value) --location $(RESOURCE_PREFIX)-location; do echo 'Waiting to set up control plane DNS...'; sleep 30; done

dns_controlplane_ready:
	until ibmcloud sat location dns ls --location $(RESOURCE_PREFIX)-location | grep $(shell cat terraform_show.json | jq --raw-output .values.outputs.ipaddress_controlplane01_floating.value); do echo 'Waiting for control plane DNS records to be registered...'; sleep 30; done

assign_controlplane:
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --zone=$(LOCATION_REGION)-1 --host=$(RESOURCE_PREFIX)-controlplane01; do echo 'Waiting to assign host to control plane'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --zone=$(LOCATION_REGION)-2 --host=$(RESOURCE_PREFIX)-controlplane02; do echo 'Waiting to assign host to control plane'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --zone=$(LOCATION_REGION)-3 --host=$(RESOURCE_PREFIX)-controlplane03; do echo 'Waiting to assign host to control plane'; sleep 30; done

assign_controlplane_ready:
	until ibmcloud sat location get --location $(RESOURCE_PREFIX)-location | grep Message | grep R0001; do echo 'Waiting for control plane to be assigned and location to be ready.'; sleep 30; done

create_cluster: target
	until ibmcloud oc cluster create satellite --location $(RESOURCE_PREFIX)-location --name $(RESOURCE_PREFIX)-cluster --version 4.5_openshift --enable-config-admin; do echo 'Waiting to create cluster...'; sleep 30; done

cluster_in_warning:
	# Cluster is ready once it moves to "warning" state (the warning is because it will have no worker nodes yet).
	until ibmcloud oc cluster get --cluster $(RESOURCE_PREFIX)-cluster 2>/dev/null | grep 'State.*warning' >/dev/null; do echo 'Waiting on cluster to move to "warning" status...'; sleep 30; done

cluster_in_normal:
	until ibmcloud oc cluster get --cluster $(RESOURCE_PREFIX)-cluster 2>/dev/null | grep 'State.*normal' >/dev/null; do echo 'Waiting on cluster to move to "normal" status...'; sleep 30; done

assign_workernodes:
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --worker-pool=default --host=$(RESOURCE_PREFIX)-workernode01 --cluster $(RESOURCE_PREFIX)-cluster; do echo 'Waiting to assign worker nodes...'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --worker-pool=default --host=$(RESOURCE_PREFIX)-workernode02 --cluster $(RESOURCE_PREFIX)-cluster; do echo 'Waiting to assign worker nodes...'; sleep 30; done
	until ibmcloud sat host assign --location $(RESOURCE_PREFIX)-location --worker-pool=default --host=$(RESOURCE_PREFIX)-workernode03 --cluster $(RESOURCE_PREFIX)-cluster; do echo 'Waiting to assign worker nodes...'; sleep 30; done

login_cluster: get_cluster_config
	oc login -u apikey -p $(IC_API_KEY)

setup_network_cluster: get_terraform_show
	$(eval NLB_HOST=$(shell ibmcloud ks nlb-dns ls --cluster $(RESOURCE_PREFIX)-cluster | tail -1 | cut -f1 -d' '))
	$(eval NLB_IP=$(shell ibmcloud ks nlb-dns ls --cluster $(RESOURCE_PREFIX)-cluster | tail -1 | cut -d' ' -f4))
	# Only remove NLB IP if there is one (seems to be unpredictable at this stage).
	-[ $(NLB_IP) != "-" ] && until ibmcloud ks nlb-dns rm classic --cluster $(RESOURCE_PREFIX)-cluster --nlb-host $(NLB_HOST) --ip $(NLB_IP); do echo 'Waiting to remove NLB IPs...'; sleep 30; done
	until ibmcloud ks nlb-dns add --cluster $(RESOURCE_PREFIX)-cluster --nlb-host $(NLB_HOST) --ip $(shell cat terraform_show.json | jq --raw-output .values.outputs.ipaddress_workernode01_floating.value); do echo 'Waiting to add NLB IPs...'; sleep 30; done

network_cluster_ready:
	until ibmcloud ks nlb-dns ls --cluster $(RESOURCE_PREFIX)-cluster | grep $(shell cat terraform_show.json | jq --raw-output .values.outputs.ipaddress_workernode01_floating.value); do echo 'Waiting for cluster DNS records to be registered...'; sleep 30; done

get_cluster_config:
	ibmcloud oc cluster config --cluster $(RESOURCE_PREFIX)-cluster

get_wireguard_config: ssh-keys/ssh-key
	# There is no point in having strict host key checking, as floating IPs may get reused and we'll only connect to this server once.
	scp -o StrictHostKeyChecking=no -i ssh-keys/ssh-key root@$(shell cd terraform && terraform output ipaddress_wireguard_floating | tr -d '"'):wireguard.client wireguard-$(RESOURCE_PREFIX).conf

all_private: login_ibmcloud
	date
	make create_location
	date
	make apply_terraform
	date
	make get_wireguard_config
	date
	make attach_host_ready
	date
	make assign_controlplane
	date
	make login_ibmcloud # Periodic relogins may be needed.
	date
	make assign_controlplane_ready
	date
	make create_cluster
	date
	make cluster_in_warning
	date
	make assign_workernodes
	date
	make cluster_in_normal
	date
	echo "Done!"

all_public: login_ibmcloud
	date
	make create_location
	date
	make apply_terraform
	date
	make attach_host_ready
	date
	make setup_dns_controlplane
	date
	make dns_controlplane_ready
	date
	make login_ibmcloud # Periodic relogins may be needed.
	date
	make assign_controlplane
	date
	make assign_controlplane_ready
	date
	make setup_dns_controlplane
	date
	make dns_controlplane_ready
	date
	make create_cluster
	date
	make cluster_in_warning
	date
	make setup_network_cluster
	date
	make network_cluster_ready
	date
	make login_ibmcloud # Periodic relogins may be needed.
	date
	make assign_workernodes
	date
	make cluster_in_normal
	date
	make setup_network_cluster
	date
	make network_cluster_ready
	date
	echo "Done!"
