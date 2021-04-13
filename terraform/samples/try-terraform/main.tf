provider "ibm" {
  region = var.IAAS_REGION
}

data "ibm_is_images" "ds_images" {
}

resource "ibm_resource_group" "group" {
  name = "${var.RESOURCE_PREFIX}-group"
}

resource "ibm_is_vpc" "vpc" {
  name           = "${var.RESOURCE_PREFIX}-vpc"
  resource_group = ibm_resource_group.group.id
}