# All these variables are supplied from the .envrc file in TF_VAR_xxx environment
# variables.

variable "RESOURCE_PREFIX" {
  type = string
  default = "sat"
}

variable "IAAS_REGION" {
  type = string
  default = "eu-de"
}

variable "IAAS_ZONE" {
  type = string
  default = "z1"
}

variable "WORKER_NODE_PROFILE" {
  type = string
  default = "bx2-4x16"
}
