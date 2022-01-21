# All these variables are supplied from the .envrc file in TF_VAR_xxx environment
# variables.

variable "IBMCLOUD_API_KEY" {
  type        = string
  default     = "6duWoBqFi4TwNJHGa558d-aF1ZxAWa-8tnihLdujWPJb"
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

