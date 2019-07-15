# Overview 



# Prerequisites
You will need to provision compute infrastructure on your IBM Cloud account in order to use the example code. IBM Cloud virtual server instances and bare metal servers can be ordered via your IBM Cloud account. Don’t have an IBM Cloud account yet? [Sign up here](https://cloud.ibm.com/registration).

 - Terraform and the IBM Terraform provider plugin installed - [guide](https://cloud.ibm.com/docs/terraform?topic=terraform-getting-started#install).
 - Ansible installed - [guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 
 - An IBM Cloud PaaS and IaaS API key. 

> If you already have Terraform v0.12 installed you will need to use a different machine or downgrade. The IBM Cloud Provider plugin only supports pre-v0.12 Terraform versions. 

# What will be provisioned

 - [IBM Cloud VLAN](https://cloud.ibm.com/catalog/infrastructure/vlan)
 - [IBM Cloud Portable Subnet](https://cloud.ibm.com/catalog/infrastructure/subnet-ip)
 - [IBM Cloud Virtual Server Instance](https://cloud.ibm.com/catalog/infrastructure/virtual-server-group)
 - [IBM Cloud Bare Metal NO OS Server](https://cloud.ibm.com/catalog/infrastructure/bare-metal)

## Download Example Code 

```
git clone https://github.com/greyhoundforty/ibm_pxe_terraform.git
cd ibm_pxe_terraform
```

## Update the `install.yml` with your local SSH Key
If you don't already have an SSH key generated, you will need to create one. The SSH key will be used to authenticate with our PXE instance for Ansible communication.

```
ssh-keygen -o -t rsa -b 4096
```

Replace your_public_ssh_key_here with your Public SSH Key in the `install.yml` file. 

```
nano/vi install.yml

```
## Configuring the provider

Copy the credentials template file and update it with your IBM Cloud details. More information about provider variables can be found [here](https://ibm-cloud.github.io/tf-ibm-docs/#authentication).

```
cp credentials.tfvars.tpl credentials.tfvars
nano/vi credentials.tfvars
```