output "private_ip" {
  value = ibm_is_instance.is_instance.primary_network_interface.0.primary_ipv4_address
}
