# All these variables are supplied from the .envrc file in TF_VAR_xxx environment
# variables.

variable "IC_API_KEY" {
  default     = "nope"
  description = "IBM Cloud API KEY"
}

variable "SSH_PUBLIC_KEY" {
  default     = "vann-fra-key"
  description = "The name(ID) of your SSH public key to be used."
}

variable "resource_group" {
  type        = string
  default     = "default"
  description = "resource group"
}

