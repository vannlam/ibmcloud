terraform {
required_version = ">=1.0.0, <2.0"
required_providers {
    ibm = {
    source = "IBM-Cloud/ibm"
    }
 }
}
# Configure the IBM Provider
provider "ibm" {
  region           = "eu-de"
  ibmcloud_api_key = var.IC_API_KEY
}
