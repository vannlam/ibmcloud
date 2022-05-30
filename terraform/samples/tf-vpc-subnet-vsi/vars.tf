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

variable "ZONE" {
  type        = string
  default     = "eu-de-3"
  description = "Deployment zone. Currently only a single zone is supported."
}

