terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.20.0"
    }
  }
}

# Configure the IBM Provider
provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.IC_API_KEY
  generation       = 2

}
