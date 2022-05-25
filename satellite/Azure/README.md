# IBM CLOUD


# Managed Redhat OpenShift by IBM Cloud on Azure using IBM Satellite

### Author : Vann Lam
#### Last update: 2022-05

## Introduction
In this document, we will be provisioning a managed IBM Cloud Openshift cluster (ROKS) in an IBM Cloud satellite location hosted in an Azure account.
We will be using an IBM Cloud account and a Microsoft Azure account.

On Azure account, we will be provisioning VMs, using Terraform scripts in IBM Cloud Schematics when creating IBM Cloud Satellite location.

# 0. Prereq on getting started on ROKS on Azure with IBM Cloud Satellite
1. You need to have an IBM Cloud account
2. You need to have a Microsoft Azure account
	(Azure Client ID, Azure tenant ID and Azure secret key) are 	sufficient
	for IBMers and IBM Business Partners, you may use Techzone 
	
## Steps to get started on ROKS on Azure with IBM Cloud Satellite
1. Create an IBM Cloud location on Azure.
2. Deploy ROKS on the location
3. Create an image registry in ROKS to a COS bucket
4. Deploy Portworx on ROKS
5. Deploy ODF on ROKS

## Log in to IBM Cloud with IBMid on a web browser

&rarr; [IBM Cloud](http://cloud.ibm.com)

<img src="files/login.png">

## Log in to IBM Cloud with CLI
### IBM Cloud CLI installation :
&rarr; [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)

### IBM Cloud CLI usage :

| Command line | Comment |
|------|-----|
| ibmcloud login | Use your IBMid credentials |
| ibmcloud login --apikey | Use your IBM Cloud Account apikey|
| ibmcloud login --sso | Use your enterprise credentials |

### How to install Azure CLI on your laptop
&rarr; [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Log in to Microsoft Azure with CLI
```
az login --service-principal
    -u < Azure Client ID > 
    -p < Azure key >
    --tenant < Azure tenant ID >
```


# 1. Create an IBM Cloud Satellite location on Azure

### Create your credentials in Techzone Azure account
This section applies to IBMers and IBM Partners only. Otherwise you need to have your own Azure credentials.

Go to &rarr; [Techzone](https://techzone.ibm.com)

And use your IBMid credentials

Search Techzone asset related to Satellite and Azure
<img src="files/location9.png">




Scroll down and Reserve your Azure environment
<img src="files/location10.png">

Feel in the form by providing some details such as opportunity number.

After approval, you'll be receiving your Azure account credentials in an email (third one from Techzone)

### Go to Satellite Locations
<img src="files/location1.png">

### Create location on Azure
<img src="files/location2.png">

### Enter Azure credentials
<img src="files/location3.png">

## Setup VMs parameters
### Choose your VMs profile and Satellite location name and “Managed from” site
Choose the "Managed from" site from IBM Cloud as closed as possible to the Azure location
<img src="files/location4.png">

### Back to location, location is available within 10 minutes
<img src="files/location5.png">
#### Wait until flag state show 'Normal'

### Terraform script within Schematics
You may check the terrraform script & logs created for this location

Go to Schematics workspaces
<img src="files/location6.png">




Choose the workspace created by the location
<img src="files/location7.png">

### Terraform plan is created and executed automatically
<img src="files/location8.png">

# 2. Deploy ROKS on a location on Azure
### Deploy OpenShift
Choose IBM Cloud Openshift Service
<img src="files/roks1.png">

Choose Satellite option
<img src="files/roks2.png">

Choose the location created previously
<img src="files/roks3.png">

### Choose your cluster’s size
Location's profile do not appear automatically, you need to 'Get values ....' after that the Warning will disappear
<img src="files/roks4.png"> 

Location's profiles will be proposed, just 'Set worker ...'
<img src="files/roks5.png"> 

"Enable cluster admin ..." is recommended, give it a name to your ROKS cluster and "Create"
<img src="files/roks6.png"> 




# 3. Create an image registry in ROKS using a COS bucket
### Choose IBM Cloud Object Storage service in the catalog
<img src="files/ir1.png">

### Create a Cloud object instance
<img src="files/ir2.png">

### Create a Cloud Object Storage bucket
<img src="files/ir3.png">

Customize your bucket
<img src="files/ir4.png">

Give it a unique name and choose a location close to the Azure location
<img src="files/ir5.png">

And "Create" the bucket
<img src="files/ir6.png">

### Create service credential for COS instance
<img src="files/ir7.png">

Give it a name and enable HMAC option
<img src="files/ir8.png">

### Retrieve your Cloud Object Storage HMAC credentials

<img src="files/ir9.png">

### Retrieve your bucket endpoint
<img src="files/ir10.png">

### Configure Openshift to use COS for the image Registry


```
ibmcloud login –apikey=<your IBM Cloud API key>
ibmcloud ks cluster config –cluster <cluster_name> --admin

oc create secret generic \
  image-registry-private-configuration-user  \
  --from-literal=REGISTRY_STORAGE_S3_ACCESSKEY=<YOUR COS ACCESS KEY> \
  --from-literal=REGISTRY_STORAGE_S3_SECRETKEY=<YOUR COS SECRET KEY> \
  --namespace openshift-image-registry

oc patch Config.v1.imageregistry.operator.openshift.io/cluster \
  --type merge -p '{"spec": {"managementState": "Managed"}}'
oc patch Config.v1.imageregistry.operator.openshift.io/cluster \
  --type merge -p '{"spec": {"storage": {"managementState": "Unmanaged",\
  "s3": {"bucket": ”<YOUR BUCKET NAME>",\
  "region": ”any-standard",\
  "regionEndpoint": ”<YOUR BUCKET ENDPOINT>",\
  "virtualHostedStyle": false}}}}'

```
### Check image Registry is well configured
<img src="files/ir11.png">


Check S3 bucket is setup correctly
<img src="files/ir12.png">

# 4. Deploy Portworx on ROKS

## Prereq to installing Portworx
1. You need at least one unformatted disk on worker nodes
2. you need to have an up and running etcd database (not the same one used by the ROKS cluster, we will be using an ETCD database provided by IBM Cloud


### Create an unformatted disk on each worker
```
# Determine which zone hosts each worker VM
AZ_RG=<Your Azure Resource Group>
$ az vm list -d -o table --resource-group ${AZ_RG}
Name                            ResourceGroup              	PowerState  PublicIps      	Fqdns	Location	Zones
--------------------------  	-------------------------  	----------  -------------  	------  ----------  -------
xx-satellite-azure-3660-vm-0  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.18           	eastus      	1
xx-satellite-azure-3660-vm-1  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.63            	eastus      	2
xx-satellite-azure-3660-vm-2  	xx-SATELLITE-AZURE-6795  	VM running	20.27.177.7            	eastus      	3
xx-satellite-azure-3660-vm-3  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.86            	eastus      	1
xx-satellite-azure-3660-vm-4  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.95            	eastus      	2
xx-satellite-azure-3660-vm-5  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.100          	eastus      	3
xx-satellite-azure-3660-vm-6  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.138          	eastus      	1
xx-satellite-azure-3660-vm-7  	xx-SATELLITE-AZURE-6795  	VM running	20.32.56.160           	eastus      	2
xx-satellite-azure-3660-vm-8  	xx-SATELLITE-AZURE-6795  	VM running 	20.27.183.73           	eastus      	3
```


### Add a non-formatted disk on each worker

### create disks for each worker supporting Portworx (here vm3 to vm8)
```
PF=xx-satellite-azure-3660
for i in 3 6; do az disk create -g ${AZ_RG} -n ${PF}-vm-${i}-disk0 --size-gb 1000 --location eastus --zone 1; done
for i in 4 7; do az disk create -g ${AZ_RG} -n ${PF}-vm-${i}-disk0 --size-gb 1000 --location eastus --zone 2; done
for i in 5 8; do az disk create -g ${AZ_RG} -n ${PF}-vm-${i}-disk0 --size-gb 1000 --location eastus --zone 3; done

# attach disk to VMs
for i in 3 4 5 6 7 8; do az vm disk attach -g ${AZ_RG} --vm-name ${PF}-vm-${i} --name ${PF}-vm-${i}-disk0; done

```
### Provision an etcd database in IBM Cloud

Choose the "Databases for etcd" service from IBM Cloud 
<img src="files/portworx1.png">

Give it a name and choose a location close to Azure location
<img src="files/portworx2.png">

Choose etcd database profile 
<img src="files/portworx3.png">

And enabled Public endpoint
<img src="files/portworx4.png">

### Provision credentials to access to the etcd database


<img src="files/portworx5.png">

Give it a name
<img src="files/portworx6.png">

And retrieve the four details needed
<img src="files/portworx7.png">

### Encrypt username and password
```
$ echo -n 671d7df029b18c263ad6f89cf5f8ac57869fe5e5c736c5f7d1dfc53a5f131aff |base64
NjcxZDdkZjAyOWIxOGMyNjNhZDZmODljZjVmOGFjNTc4NjlmZTVlNWM3MzZjNWY3ZDFkZmM1M2E1ZjEzMWFmZg==
$ echo -n ibm_cloud_ff251c13_88e7_459f_8d3e_d7474bf952a6 | base64
aWJtX2Nsb3VkX2ZmMjUxYzEzXzg4ZTdfNDU5Zl84ZDNlX2Q3NDc0YmY5NTJhNg==

```

### Create a file secret-etcd.yaml to store your etcd credentials and create the secret in the ROKS cluster

```
apiVersion: v1
kind: Secret
metadata:
  name: px-etcd-certs
  namespace: kube-system
type: Opaque
data:
  ca.pem:"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURIVENDQWdXZ0F3SUJBZ0lVTDVnNnQxSG1OT3Q4T09xVVd5dVFaZVdzclVBd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0hqRWNNQm9HQTFVRUF3d1RTVUpOSUVOc2IzVmtJRVJoZEdGaVlYTmxjekFlRncweE9ERXhNakV4TVRRMwpNamRhRncweU9ERXhNVGd4TVRRM01qZGFNQjR4SERBYUJnTlZCQU1NRTBsQ1RTQkRiRzkxWkNCRVlYUmhZbUZ6ClpYTXdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDM2h4Zm9zWWVYZG1yUVJIbFUKdk1nOTFJV1NDdUdaMTZSYkhiWjJwNjJTRVVmQkplbXI0TWtUcjQ4WVpUZmlUQ1pqY2tXV0dsQmx2VVlyMGNZWQpLTTNPUHRraGszbG1rQVFsSmNNQ1BmaUYyK21CeEFVcXJJaWJDZ21RaWp5bFJKVzRzRUZRZ1Niclhld0R5d0VkCjhKVWdtKzgyRHdMWXk2dm5rS0pqemNVWms1T0tTMVV2N3cwcEhVdFVNdE5MYVN5S2tzRGRFOWQ5c2o2bFdURkoKVzlDeVhDcDVpZmZKOTdvZXdJaDQ3bklGWVU1RDVNcHRDRFlyNndpZk9XdmhpZHVZRDZXTVI3d0RnTE12L3JhOQpadDRudDdNWWdsUm1Lbk83N0RaSTVZOWxUNGd3NEZpVTBrNjVhV25YcmsrMURaNGpxRmRXazNWcG9YaEEwSXVYClpNYlBBZ01CQUFHalV6QlJNQjBHQTFVZERnUVdCQlFZV1RYNGRzVUwzL0xuUUFYUUxMemg0NnlEQVRBZkJnTlYKSFNNRUdEQVdnQlFZV1RYNGRzVUwzL0xuUUFYUUxMemg0NnlEQVRBUEJnTlZIUk1CQWY4RUJUQURBUUgvTUEwRwpDU3FHU0liM0RRRUJDd1VBQTRJQkFRQVB3WXJPSVFNRXJlTnVIWS82OGxGSmltQjZHQ2luR3NKdzhZSUJCUXdBCnRkSk1PWFU4YlhHckVIRXVaNlFhaG83UTVkVjJiQjZHVktUTXFoU0VkcnZ1eXhLbmlROTBqZGtRU2syVkhoRGUKSCs2aTA0aEE5VGtLVDZvb0x3TVBjMUxZWXpxRGxqRWtmS2xMSVBXQ2tPQW96RDNjeWMyNnBWLzM1bkc3V3pBRgp4dzdTM2pBeUIzV2NKRGxXbFNXR1RuNTh3M0VIeHpWWHZLVDZZOWVBZEtwNFNqVUh5VkZzTDV4dFN5akg4enBGCnBaS0s4d1dOVXdnV1E2Nk1OaDhDa3E3MzJKWitzbzZSQWZiNEJiTmo0NUkzczlmdVpTWWx2amtjNS8rZGEzQ2sKUnA2YW5YNU42eUlyemhWbUFnZWZqUWRCenRZemRmUGhzSkJrUy9URG5SbWsKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
username: "aWJtX2Nsb3VkX2ZmMjUxYzEzXzg4ZTdfNDU5Zl84ZDNlX2Q3NDc0YmY5NTJhNg=="
password: "NjcxZDdkZjAyOWIxOGMyNjNhZDZmODljZjVmOGFjNTc4NjlmZTVlNWM3MzZjNWY3ZDFkZmM1M2E1ZjEzMWFmZg=="

```

```
$oc create –f secret-etcd.yaml

```

### Install Portworx on your ROKS cluster

Choose "Portworx" service in IBM Cloud catalog
<img src="files/portworx8.png">

Fill in the form by providing all the details from the previous step
<img src="files/portworx9.png">

### Check Portworx on your ROKS cluster

Check Portworx pods
<img src="files/portworx10.png">

Check Portworx Storage Class
<img src="files/portworx11.png">

# 5. Deploy Openshift Data Foundation

### To be completed ...