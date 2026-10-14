variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "tok04", "us-east", "us-south", "dal10", "dal12", "dal14", "tor01", "osa21", "sao01", "sao04", "sao05", "mon01", "wdc06", "wdc07", "mad02", "mad04", "che02", "che03"], var.powervs_zone)
    error_message = "Only Following DC values are supported :  syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, tok04, us-east, us-south, dal10, dal12, dal14, tor01, osa21, sao01, sao04,sao05, mon01, wdc06, wdc07,mad02, mad04, che02, che03"
  }
}

###########################################
# PowerVS Workspace module variables
############################################

variable "powervs_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If null, a new resource group will be created. using the prefix variable."
  default     = "france-vla"
}

variable "prefix" {
  description = "Prefix for resources which will be created."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Name of IBM Cloud PowerVS workspace which will be created."
  type        = string
  default     = "powervs-workspace"
}

variable "powervs_ssh_public_key" {
  description = "Value of the Public SSH key to create."
  type        = string
}

variable "powervs_private_subnet_1" {
  description = "IBM Cloud PowerVS first private subnet name and cidr which will be created. Set value to null to not create this subnet."
  type = object({
    name          = string
    cidr          = string
    advertise     = optional(string)
    arp_broadcast = optional(string)
  })
  default = {
    name = "sub_1"
    cidr = "10.51.0.0/24"
  }
}

variable "powervs_private_subnet_2" {
  description = "IBM Cloud PowerVS second private subnet name and cidr which will be created. Set value to null to not create this subnet."
  type = object({
    name          = string
    cidr          = string
    advertise     = optional(string)
    arp_broadcast = optional(string)
  })
  default = {
    name = "sub_2"
    cidr = "10.53.0.0/24"
  }
}

variable "powervs_user_tags" {
  description = "List of Tag names for IBM Cloud PowerVS instance and volumes. Can be set to null."
  type        = list(string)
  default     = ["pi-basic"]
}

variable "powervs_user_data" {
  description = "The user data cloud-init to pass to the instance during creation. It can be a base64 encoded or an unencoded string. If it is an unencoded string, the provider will encode it before it passing it down."
  type        = string
  default     = null
}

#####################################################
# PowerVS Instance Parameters
#####################################################

variable "powervs_instance_name" {
  description = "Name of instance which will be created."
  type        = string
  default     = "pi"
}

variable "powervs_os_image_name" {
  description = "Image Name for PowerVS Instance."
  type        = string
  default     = "SLES15-SP6"
}

variable "powervs_sap_profile_id" {
  description = "SAP Profile ID for the amount of cores and memory. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). Required only when creating SAP instances. If this is mentioned then powervs_server_type, powervs_cpu_proc_type, powervs_number_of_processors and powervs_memory_size will not be taken into account."
  type        = string
  default     = null
}

variable "powervs_boot_image_storage_tier" {
  description = "Storage type for server deployment.Possible values tier0, tier1 and tier3"
  type        = string
  default     = "tier1"
}

variable "powervs_server_type" {
  description = "The type of system on which to create the VM. Supported values are e980/s922/e1080/s1022. Required when not creating SAP instances. Conflicts with 'powervs_sap_profile_id'."
  type        = string
  default     = "s1022"
}

variable "powervs_cpu_proc_type" {
  description = "The type of processor mode in which the VM will run with shared, capped or dedicated. Required when not creating SAP instances. Conflicts with 'powervs_sap_profile_id'."
  type        = string
  default     = "shared"
}

variable "powervs_number_of_processors" {
  description = "The number of vCPUs to assign to the VM as visible within the guest Operating System. Required when not creating SAP instances. Conflicts with 'powervs_sap_profile_id'."
  type        = string
  default     = 2
}

variable "powervs_memory_size" {
  description = "The amount of memory that you want to assign to your instance in GB. Required when not creating SAP instances. Conflicts with 'powervs_sap_profile_id'."
  type        = string
  default     = 4
}

variable "powervs_storage_config" {
  description = "Custom File systems to be created and attached to PowerVS instance. 'disk_size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the mount point on the OS.'pool' specifies the volume pool where the volume will be created. 'sharable' specifies if volume can be shared across PVM instances."
  type = list(object({
    name     = string
    size     = string
    count    = string
    tier     = string
    mount    = string
    pool     = optional(string)
    sharable = optional(bool)
  }))

  default = [
    {
      name = "data", size = "100", count = "1", tier = "tier1", mount = "/data"
    }
  ]
}