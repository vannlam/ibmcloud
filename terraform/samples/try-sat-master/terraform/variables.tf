# All these variables are supplied from the .envrc file in TF_VAR_xxx environment
# variables.

variable "RESOURCE_PREFIX" {
  type = string
}

variable "IAAS_REGION" {
  type = string
}

variable "IAAS_ZONE" {
  type = string
}

variable "WORKER_NODE_PROFILE" {
  type = string
  default = "bx2-4x16"
}