# Basic Power Virtual Server infrastructure with a Power Virtual Server instance

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=powervs-instance-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance/tree/main/examples/basic">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

This example illustrates how to use the `powervs-workspace` &`powervs-instance` module.
It provisions the following infrastructure:
- Creates a [Resource group](https://github.com/terraform-ibm-modules/terraform-ibm-resource-group).
- Creates a [PowerVS Workspace](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-worksoace) calling root module which creates workspace, ssh key, 2 private subnets and imports images.<br/>
- Creates an IBM® Power Virtual Server Instance.
- Creates volumes and attaches it to the instance.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.85.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_instance"></a> [powervs\_instance](#module\_powervs\_instance) | ../../ | n/a |
| <a name="module_powervs_workspace"></a> [powervs\_workspace](#module\_powervs\_workspace) | terraform-ibm-modules/powervs-workspace/ibm | 5.1.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.6.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_pi_catalog_images.catalog_images_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_catalog_images) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_boot_image_storage_tier"></a> [powervs\_boot\_image\_storage\_tier](#input\_powervs\_boot\_image\_storage\_tier) | Storage type for server deployment.Possible values tier0, tier1 and tier3 | `string` | `"tier1"` | no |
| <a name="input_powervs_cpu_proc_type"></a> [powervs\_cpu\_proc\_type](#input\_powervs\_cpu\_proc\_type) | The type of processor mode in which the VM will run with shared, capped or dedicated. Required when not creating SAP instances. Conflicts with 'powervs\_sap\_profile\_id'. | `string` | `"shared"` | no |
| <a name="input_powervs_instance_name"></a> [powervs\_instance\_name](#input\_powervs\_instance\_name) | Name of instance which will be created. | `string` | `"pi"` | no |
| <a name="input_powervs_memory_size"></a> [powervs\_memory\_size](#input\_powervs\_memory\_size) | The amount of memory that you want to assign to your instance in GB. Required when not creating SAP instances. Conflicts with 'powervs\_sap\_profile\_id'. | `string` | `4` | no |
| <a name="input_powervs_number_of_processors"></a> [powervs\_number\_of\_processors](#input\_powervs\_number\_of\_processors) | The number of vCPUs to assign to the VM as visible within the guest Operating System. Required when not creating SAP instances. Conflicts with 'powervs\_sap\_profile\_id'. | `string` | `2` | no |
| <a name="input_powervs_os_image_name"></a> [powervs\_os\_image\_name](#input\_powervs\_os\_image\_name) | Image Name for PowerVS Instance. | `string` | `"SLES15-SP6"` | no |
| <a name="input_powervs_private_subnet_1"></a> [powervs\_private\_subnet\_1](#input\_powervs\_private\_subnet\_1) | IBM Cloud PowerVS first private subnet name and cidr which will be created. Set value to null to not create this subnet. | <pre>object({<br/>    name          = string<br/>    cidr          = string<br/>    advertise     = optional(string)<br/>    arp_broadcast = optional(string)<br/>  })</pre> | <pre>{<br/>  "cidr": "10.51.0.0/24",<br/>  "name": "sub_1"<br/>}</pre> | no |
| <a name="input_powervs_private_subnet_2"></a> [powervs\_private\_subnet\_2](#input\_powervs\_private\_subnet\_2) | IBM Cloud PowerVS second private subnet name and cidr which will be created. Set value to null to not create this subnet. | <pre>object({<br/>    name          = string<br/>    cidr          = string<br/>    advertise     = optional(string)<br/>    arp_broadcast = optional(string)<br/>  })</pre> | <pre>{<br/>  "cidr": "10.53.0.0/24",<br/>  "name": "sub_2"<br/>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | The name of an existing resource group to provision resources in to. If null, a new resource group will be created. using the prefix variable. | `string` | `null` | no |
| <a name="input_powervs_sap_profile_id"></a> [powervs\_sap\_profile\_id](#input\_powervs\_sap\_profile\_id) | SAP Profile ID for the amount of cores and memory. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). Required only when creating SAP instances. If this is mentioned then powervs\_server\_type, powervs\_cpu\_proc\_type, powervs\_number\_of\_processors and powervs\_memory\_size will not be taken into account. | `string` | `null` | no |
| <a name="input_powervs_server_type"></a> [powervs\_server\_type](#input\_powervs\_server\_type) | The type of system on which to create the VM. Supported values are e980/s922/e1080/s1022. Required when not creating SAP instances. Conflicts with 'powervs\_sap\_profile\_id'. | `string` | `"s1022"` | no |
| <a name="input_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#input\_powervs\_ssh\_public\_key) | Value of the Public SSH key to create. | `string` | n/a | yes |
| <a name="input_powervs_storage_config"></a> [powervs\_storage\_config](#input\_powervs\_storage\_config) | Custom File systems to be created and attached to PowerVS instance. 'disk\_size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the mount point on the OS.'pool' specifies the volume pool where the volume will be created. 'sharable' specifies if volume can be shared across PVM instances. | <pre>list(object({<br/>    name     = string<br/>    size     = string<br/>    count    = string<br/>    tier     = string<br/>    mount    = string<br/>    pool     = optional(string)<br/>    sharable = optional(bool)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "1",<br/>    "mount": "/data",<br/>    "name": "data",<br/>    "size": "100",<br/>    "tier": "tier1"<br/>  }<br/>]</pre> | no |
| <a name="input_powervs_user_data"></a> [powervs\_user\_data](#input\_powervs\_user\_data) | The user data cloud-init to pass to the instance during creation. It can be a base64 encoded or an unencoded string. If it is an unencoded string, the provider will encode it before it passing it down. | `string` | `null` | no |
| <a name="input_powervs_user_tags"></a> [powervs\_user\_tags](#input\_powervs\_user\_tags) | List of Tag names for IBM Cloud PowerVS instance and volumes. Can be set to null. | `list(string)` | <pre>[<br/>  "pi-basic"<br/>]</pre> | no |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Name of IBM Cloud PowerVS workspace which will be created. | `string` | `"powervs-workspace"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resources which will be created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_pi_images"></a> [pi\_images](#output\_pi\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_pi_instance_primary_ip"></a> [pi\_instance\_primary\_ip](#output\_pi\_instance\_primary\_ip) | IP address of the primary network interface of IBM PowerVS instance. |
| <a name="output_pi_instance_private_ips"></a> [pi\_instance\_private\_ips](#output\_pi\_instance\_private\_ips) | All private IP addresses (as a list) of IBM PowerVS instance. |
| <a name="output_pi_private_subnet_1"></a> [pi\_private\_subnet\_1](#output\_pi\_private\_subnet\_1) | Created PowerVS private subnet 1 details. |
| <a name="output_pi_private_subnet_2"></a> [pi\_private\_subnet\_2](#output\_pi\_private\_subnet\_2) | Created PowerVS private subnet 2 details. |
| <a name="output_pi_resource_group_name"></a> [pi\_resource\_group\_name](#output\_pi\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_pi_ssh_public_key"></a> [pi\_ssh\_public\_key](#output\_pi\_ssh\_public\_key) | SSH public key name in created PowerVS infrastructure. |
| <a name="output_pi_storage_configuration"></a> [pi\_storage\_configuration](#output\_pi\_storage\_configuration) | Storage configuration of PowerVS instance. |
| <a name="output_pi_workspace_guid"></a> [pi\_workspace\_guid](#output\_pi\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_pi_workspace_id"></a> [pi\_workspace\_id](#output\_pi\_workspace\_id) | PowerVS infrastructure workspace id. The unique identifier of the new resource instance. |
| <a name="output_pi_workspace_name"></a> [pi\_workspace\_name](#output\_pi\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_pi_zone"></a> [pi\_zone](#output\_pi\_zone) | Zone where PowerVS infrastructure is created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
