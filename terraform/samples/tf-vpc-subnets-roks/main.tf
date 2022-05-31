
data "ibm_is_ssh_key" "ssh_key" {
  name = var.SSH_PUBLIC_KEY
}

resource "ibm_is_vpc" "vpc1" {
  name = "vpcroks"
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "mysubnet1"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = "eu-de-1"
  total_ipv4_address_count = 256
}

resource "ibm_is_subnet" "subnet2" {
  name                     = "mysubnet2"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = "eu-de-2"
  total_ipv4_address_count = 256
}

resource "ibm_is_subnet" "subnet3" {
  name                     = "mysubnet3"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = "eu-de-3"
  total_ipv4_address_count = 256
}

resource "ibm_is_public_gateway" "pgw-z1" {
  name = "pgw-z1"
  vpc  = ibm_is_vpc.vpc1.id
  zone = "eu-de-1"
}

resource "ibm_is_public_gateway" "pgw-z2" {
  name = "pgw-z2"
  vpc  = ibm_is_vpc.vpc1.id
  zone = "eu-de-2"
}

resource "ibm_is_public_gateway" "pgw-z3" {
  name = "pgw-z3"
  vpc  = ibm_is_vpc.vpc1.id
  zone = "eu-de-3"
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

data "ibm_resource_instance" "cos_instance" {
  name = "COS"
  service = "cloud-object-storage"
}

data "ibm_is_zones" "reg" {
  region = "eu-de"
}

locals {
  zn = [
    {
      name = "eu-de-1"
      subid = ibm_is_subnet.subnet1.id
    },
    {
      name = "eu-de-2"
      subid = ibm_is_subnet.subnet2.id
    },
    {
      name = "eu-de-3"
      subid = ibm_is_subnet.subnet3.id
    }
  ]
}

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "my_vpc_cluster"
  vpc_id            = ibm_is_vpc.vpc1.id
  kube_version      = "4.9.28_openshift"
  cos_instance_crn  = data.ibm_resource_instance.cos_instance.id
  flavor            = "bx2.4x16"
  worker_count      = 2      # per zone
  resource_group_id = data.ibm_resource_group.resource_group.id

  dynamic zones {
      for_each    = local.zn
      content {
        name      = zones.value.name
        subnet_id = zones.value.subid
      }
  }

}