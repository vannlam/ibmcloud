provider "ibm" {
  region = var.IAAS_REGION
}

locals {
  metro_map = {
    eu-gb   = "lon",
    us-east = "wdc"
  }

  metro = lookup(local.metro_map, lower(var.LOCATION_REGION), "lon")
}

# https://cloud.ibm.com/docs/vpc?topic=solution-tutorials-vpc-public-app-private-backend

# Documentation: https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-vpc-gen2-resources

# ***********
# These resources are created in separate steps, as they are pre-reqs for
# the Satellite location. When/if the Satellite location is instead created from
# Terraform, this split will no longer be necessary.
# ***********

resource "ibm_resource_group" "group" {
  name = "${var.RESOURCE_PREFIX}-group"
}

resource "ibm_resource_instance" "location_cos_instance" {
  name              = "${var.RESOURCE_PREFIX}-location-cos-instance"
  resource_group_id = ibm_resource_group.group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}

resource "ibm_cos_bucket" "location_cos_bucket" {
  bucket_name          = "${var.RESOURCE_PREFIX}-location-cos-bucket"
  resource_instance_id = ibm_resource_instance.location_cos_instance.id
  region_location      = var.IAAS_REGION
  storage_class        = "standard"
}

# ***********

resource "ibm_satellite_location" "location" {
  location          = "${var.RESOURCE_PREFIX}-location"
  zones             = ["location-zone-1", "location-zone-2", "location-zone-3"]
  managed_from      = local.metro
  resource_group_id = ibm_resource_group.group.id

  cos_config {
    bucket = ibm_cos_bucket.location_cos_bucket.bucket_name
    region = var.IAAS_REGION
  }
}

data "ibm_is_images" "ds_images" {
}

data "local_file" "ssh_public_key" {
  filename = "../ssh-keys/ssh-key.pub"
}

resource "ibm_is_ssh_key" "ssh-key" {
  name           = "${var.RESOURCE_PREFIX}-key"
  public_key     = data.local_file.ssh_public_key.content
  resource_group = ibm_resource_group.group.id
}

resource "ibm_is_vpc" "vpc" {
  name           = "${var.RESOURCE_PREFIX}-vpc"
  resource_group = ibm_resource_group.group.id
}

resource "ibm_is_subnet" "subnet-1" {
  name                     = "${var.RESOURCE_PREFIX}-subnet-1"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = ibm_resource_group.group.id
  total_ipv4_address_count = "256"
  public_gateway           = ibm_is_public_gateway.public-gateway-1.id
  zone                     = "${var.IAAS_REGION}-1"

  //User can configure timeouts
  timeouts {
    create = "90m"
    delete = "30m"
  }
}

resource "ibm_is_subnet" "subnet-2" {
  name                     = "${var.RESOURCE_PREFIX}-subnet-2"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = ibm_resource_group.group.id
  total_ipv4_address_count = "256"
  public_gateway           = ibm_is_public_gateway.public-gateway-2.id
  zone                     = "${var.IAAS_REGION}-2"

  //User can configure timeouts
  timeouts {
    create = "90m"
    delete = "30m"
  }
}

resource "ibm_is_subnet" "subnet-3" {
  name                     = "${var.RESOURCE_PREFIX}-subnet-3"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = ibm_resource_group.group.id
  total_ipv4_address_count = "256"
  public_gateway           = ibm_is_public_gateway.public-gateway-3.id
  zone                     = "${var.IAAS_REGION}-3"

  //User can configure timeouts
  timeouts {
    create = "90m"
    delete = "30m"
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-ssh" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

# Port 80 is needed for default routes into OpenShift. A TODO is to figure out
# how to do this securely using HTTPS instead.
resource "ibm_is_security_group_rule" "sg-rule-inbound-http" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-https" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-api" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-api2" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  udp {
    port_min = 30000
    port_max = 32767
  }
}

resource "ibm_is_security_group_rule" "sg-rule-inbound-icmp" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "sg-rule-outbound" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "outbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 1
    port_max = 65535
  }
}

# Hosts must have TCP/UDP/ICMP Layer 3 connectivity for all ports across hosts.
# You cannot block access to certain ports that might block communication across hosts.
resource "ibm_is_security_group_rule" "sg-rule-inbound-from-the-group" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "inbound"
  remote    = ibm_is_vpc.vpc.security_group[0].group_id
}

resource "ibm_is_security_group_rule" "sg-rule-outbound-to-the-group" {
  group     = ibm_is_vpc.vpc.security_group[0].group_id
  direction = "outbound"
  remote    = ibm_is_vpc.vpc.security_group[0].group_id
}

resource "ibm_is_public_gateway" "public-gateway-1" {
  name           = "${var.RESOURCE_PREFIX}-public-gateway-1"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "${var.IAAS_REGION}-1"
  resource_group = ibm_resource_group.group.id

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_public_gateway" "public-gateway-2" {
  name           = "${var.RESOURCE_PREFIX}-public-gateway-2"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "${var.IAAS_REGION}-2"
  resource_group = ibm_resource_group.group.id

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_public_gateway" "public-gateway-3" {
  name           = "${var.RESOURCE_PREFIX}-public-gateway-3"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "${var.IAAS_REGION}-3"
  resource_group = ibm_resource_group.group.id

  //User can configure timeouts
  timeouts {
    create = "90m"
  }
}

module "is_instance_controlplane01" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-controlplane01"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-1.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-1"
  node_role            = "controlplane01"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  bastion_host         = module.wireguard.vsi_floating_ip
  create_floating_ip   = var.CREATE_FLOATING_IP
}

module "is_instance_controlplane02" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-controlplane02"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-2.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-2"
  node_role            = "controlplane02"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  bastion_host         = module.wireguard.vsi_floating_ip
  create_floating_ip   = var.CREATE_FLOATING_IP

}

module "is_instance_controlplane03" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-controlplane03"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-3.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-3"
  node_role            = "controlplane03"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  bastion_host         = module.wireguard.vsi_floating_ip
  create_floating_ip   = var.CREATE_FLOATING_IP
}

module "is_instance_workernode01" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-workernode01"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-1.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-1"
  node_role            = "workernode01"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  profile              = var.WORKER_NODE_PROFILE
  bastion_host         = module.wireguard.vsi_floating_ip
  create_floating_ip   = var.CREATE_FLOATING_IP
}

module "is_instance_workernode02" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-workernode02"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-2.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-2"
  node_role            = "workernode02"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  profile              = var.WORKER_NODE_PROFILE
  bastion_host         = module.wireguard.vsi_floating_ip
  create_floating_ip   = var.CREATE_FLOATING_IP
}

module "is_instance_workernode03" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-workernode03"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-3.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-3"
  node_role            = "workernode03"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  profile              = var.WORKER_NODE_PROFILE
  bastion_host         = module.wireguard.vsi_floating_ip
  create_floating_ip   = var.CREATE_FLOATING_IP
}

module "wireguard" {
  source = "./modules/vsi-ubuntu-wireguard"

  zone                 = "${var.IAAS_REGION}-1"
  basename             = var.RESOURCE_PREFIX
  region               = var.IAAS_REGION
  resource_group       = ibm_resource_group.group.id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  ssh_private_key_file = "../ssh-keys/ssh-key"
  cidrs                = ["${module.is_instance_controlplane01.private_ip}/32", "${module.is_instance_controlplane02.private_ip}/32", "${module.is_instance_controlplane03.private_ip}/32", "${module.is_instance_workernode01.private_ip}/32", "${module.is_instance_workernode02.private_ip}/32", "${module.is_instance_workernode03.private_ip}/32"]
}

resource "ibm_resource_instance" "logdna" {
  name     = "${var.RESOURCE_PREFIX}-logdna"
  service  = "logdna"
  plan     = "7-day"
  location = var.LOCATION_REGION

  resource_group_id = ibm_resource_group.group.id
}

resource "ibm_resource_key" "logdna_key" {
  name                 = "${var.RESOURCE_PREFIX}-logdna-key-admin"
  role                 = "Administrator"
  resource_instance_id = ibm_resource_instance.logdna.id
}

/*****************************************
*
*     On-prem instance creation. This part creates an instance for simulating a client's on-prem resource. 
*
*****************************************/

module "on_prem_instance" {
  source = "./modules/on-prem-instance"

  name                 = "${var.RESOURCE_PREFIX}-onprem-db"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet-2.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = "${var.IAAS_REGION}-2"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  bastion_host         = module.wireguard.vsi_floating_ip
}
