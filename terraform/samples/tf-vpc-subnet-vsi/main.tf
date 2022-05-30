
data "ibm_is_ssh_key" "ssh_key" {
  name = var.SSH_PUBLIC_KEY
}

resource "ibm_is_vpc" "testacc_vpc" {
  name = "terra-test"
}

resource "ibm_is_vpc_address_prefix" "testacc_vpc_address_prefix" {
  name = "prefix-z3"
  zone = "eu-de-3"
  vpc  = ibm_is_vpc.testacc_vpc.id
  cidr = "10.240.0.0/22"
}

resource "ibm_is_subnet" "testacc_subnet" {
  name            = "my-z3-subnet"
  vpc             = ibm_is_vpc.testacc_vpc.id
  zone            = "eu-de-3"
  ipv4_cidr_block = "10.240.0.0/24"
}

resource "ibm_is_instance" "testacc_instance" {
  name    = "my-centos-instance"
  image   = "r010-067bd38b-7ddd-49d9-a7f3-6e0a798e0554"
  profile = "cx2-2x4"

  primary_network_interface {
    subnet = ibm_is_subnet.testacc_subnet.id
  }

  vpc  = ibm_is_vpc.testacc_vpc.id
  zone = "eu-de-3"
  keys = [data.ibm_is_ssh_key.ssh_key.id]
}
