provider "ibm" {
  region = var.IAAS_REGION
}

# https://cloud.ibm.com/docs/vpc?topic=solution-tutorials-vpc-public-app-private-backend

# Documentation: https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform?topic=ibm-cloud-provider-for-terraform-vpc-gen2-resources

data "ibm_is_images" "ds_images" {
}

resource "ibm_resource_group" "group" {
  name = "${var.RESOURCE_PREFIX}-group"
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

resource "ibm_is_subnet" "subnet" {
  name                     = "${var.RESOURCE_PREFIX}-subnet"
  vpc                      = ibm_is_vpc.vpc.id
  resource_group           = ibm_resource_group.group.id
  total_ipv4_address_count = "256"
  public_gateway           = ibm_is_public_gateway.public-gateway.id
  zone                     = var.IAAS_ZONE

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

resource "ibm_is_public_gateway" "public-gateway" {
  name           = "${var.RESOURCE_PREFIX}-public-gateway"
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.IAAS_ZONE
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
  subnet_id            = ibm_is_subnet.subnet.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = var.IAAS_ZONE
  node_role            = "controlplane01"
  ssh_private_key_file = "../ssh-keys/ssh-key"
}

module "is_instance_controlplane02" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-controlplane02"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = var.IAAS_ZONE
  node_role            = "controlplane02"
  ssh_private_key_file = "../ssh-keys/ssh-key"
}

module "is_instance_controlplane03" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-controlplane03"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = var.IAAS_ZONE
  node_role            = "controlplane03"
  ssh_private_key_file = "../ssh-keys/ssh-key"

}

module "is_instance_workernode01" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-workernode01"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = var.IAAS_ZONE
  node_role            = "workernode01"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  profile              = var.WORKER_NODE_PROFILE
}

module "is_instance_workernode02" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-workernode02"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = var.IAAS_ZONE
  node_role            = "workernode02"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  profile              = var.WORKER_NODE_PROFILE
}

module "is_instance_workernode03" {
  source = "./modules/is_instance"

  name                 = "${var.RESOURCE_PREFIX}-workernode03"
  resource_group       = ibm_resource_group.group.id
  subnet_id            = ibm_is_subnet.subnet.id
  security_group_id    = ibm_is_vpc.vpc.security_group[0].group_id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  zone                 = var.IAAS_ZONE
  node_role            = "workernode03"
  ssh_private_key_file = "../ssh-keys/ssh-key"
  profile              = var.WORKER_NODE_PROFILE
}

module "wireguard" {
  source = "./modules/vsi-ubuntu-wireguard"

  zone                 = var.IAAS_ZONE
  basename             = var.RESOURCE_PREFIX
  region               = var.IAAS_REGION
  resource_group       = ibm_resource_group.group.id
  vpc_id               = ibm_is_vpc.vpc.id
  ssh_key_id           = ibm_is_ssh_key.ssh-key.id
  ssh_private_key_file = "../ssh-keys/ssh-key"
  cidrs                = ["${module.is_instance_controlplane01.private_ip}/32", "${module.is_instance_controlplane02.private_ip}/32", "${module.is_instance_controlplane03.private_ip}/32", "${module.is_instance_workernode01.private_ip}/32", "${module.is_instance_workernode02.private_ip}/32", "${module.is_instance_workernode03.private_ip}/32"]
}
