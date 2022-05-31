# All these variables are supplied from the .envrc file in TF_VAR_xxx environment
# variables.

variable "region" {
  default     = "eu-de"               # au-syd, jp-osa, jp-tok, br-sao, ca-tor, eu-de, eu-gb, us-east, us-south
  description = "IBM Cloud region"
}

variable "vpcname" {
  default     = "myvpctest"
  description = "IBM Cloud vpc name"
}

variable "numworkers" {
  default     = 1
  description = "Number of workers per zone"
}

variable "workerflavor" {
  default     = "bx2.4x16"            # depends on region  cx2.2x4, bx2.2x8, mx2,2x16, ...
  description = "Worker flavor"
}

variable "kversion" {
  default     = "1.22.9"            # depends on region for roks 4.10.9_openshift, 4.8.36_openshift, ..., for k8s 1.23.6, 1.22.9, 1.21.12
  description = "k8s or Openshift version"
}



##############################
variable "IC_API_KEY" {
  default     = "nope"
  description = "IBM Cloud API KEY"
}

variable "SSH_PUBLIC_KEY" {
  default     = "vann-fra-key"        # must suits region chosen
  description = "The name(ID) of your SSH public key to be used."
}

variable "resource_group" {
  type        = string
  default     = "default"
  description = "resource group"
}

