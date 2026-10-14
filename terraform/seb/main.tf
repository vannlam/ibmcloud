########################################
#  Create / Reuse Resource group
########################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.powervs_resource_group_name == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.powervs_resource_group_name
}

####################################################
# Create a new PowerVS Workspace
#####################################################

locals {
  powervs_ssh_public_key = { name = "${var.prefix}-${var.powervs_zone}-pi-ssh-key", value = var.powervs_ssh_public_key }
}

module "powervs_workspace" {
  depends_on = [module.resource_group]
  source     = "terraform-ibm-modules/powervs-workspace/ibm"
  version    = "5.1.0"

  pi_zone                = var.powervs_zone
  pi_resource_group_name = module.resource_group.resource_group_name
  pi_workspace_name      = "${var.prefix}-${var.powervs_zone}-${var.powervs_workspace_name}"
  pi_ssh_public_key      = local.powervs_ssh_public_key
  pi_private_subnet_1    = var.powervs_private_subnet_1
  pi_private_subnet_2    = var.powervs_private_subnet_2
  pi_tags                = var.powervs_user_tags
}

data "ibm_pi_catalog_images" "catalog_images_ds" {
  pi_cloud_instance_id = module.powervs_workspace.pi_workspace_guid
  sap                  = true
  vtl                  = true
}

locals {
  catalog_images = {
    for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images :
    stock_image.name => stock_image.image_id
  }
}

#####################################################
# Deploy PowerVS Instance
#####################################################

module "powervs_instance" {
  source = "terraform-ibm-modules/powervs-instance/ibm"

  pi_workspace_guid          = module.powervs_workspace.pi_workspace_guid
  pi_ssh_public_key_name     = local.powervs_ssh_public_key.name
  pi_image_id                = lookup(local.catalog_images, var.powervs_os_image_name, null)
  pi_networks                = [module.powervs_workspace.pi_private_subnet_1, module.powervs_workspace.pi_private_subnet_2]
  pi_instance_name           = "${var.prefix}-${var.powervs_instance_name}"
  pi_sap_profile_id          = var.powervs_sap_profile_id
  pi_boot_image_storage_tier = var.powervs_boot_image_storage_tier
  pi_server_type             = var.powervs_server_type
  pi_number_of_processors    = var.powervs_number_of_processors
  pi_memory_size             = var.powervs_memory_size
  pi_cpu_proc_type           = var.powervs_cpu_proc_type
  pi_storage_config          = var.powervs_storage_config
  pi_user_tags               = var.powervs_user_tags
  pi_user_data               = var.powervs_user_data
}