#####################################################
# PowerVS Instance Module
#####################################################

terraform {
  required_version = ">= 1.13"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=2.5.0"
    }
  }
}