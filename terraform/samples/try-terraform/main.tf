
data "ibm_is_ssh_key" "ssh_key" {
  name = var.SSH_PUBLIC_KEY
}

resource "ibm_is_vpc" "testacc_vpc" {
  name = "testvpc"
}

resource "ibm_is_vpc_address_prefix" "testacc_vpc_address_prefix" {
  name = "test"
  zone = "eu-de-3"
  vpc  = ibm_is_vpc.testacc_vpc.id
  cidr = "10.240.0.0/22"
}

resource "ibm_is_subnet" "testacc_subnet" {
  name            = "testsubnet"
  vpc             = ibm_is_vpc.testacc_vpc.id
  zone            = "eu-de-3"
  ipv4_cidr_block = "10.240.0.0/24"
}

resource "ibm_is_instance" "testacc_instance" {
  name    = "testinstance"
  image   = "r010-28e8b4ba-6ab7-4af8-a01c-d9c38ccb3203"
  profile = "cx2-2x4"

  primary_network_interface {
    subnet = ibm_is_subnet.testacc_subnet.id
  }

  vpc  = ibm_is_vpc.testacc_vpc.id
  zone = "eu-de-3"
  keys = [data.ibm_is_ssh_key.ssh_key.id]
}
