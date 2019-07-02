# ibm_pxe_terraform
Example of how to deploy a PXE VSI. The code in this example will:
 - Create a new VLAN for PXE deployment environment
 - Create a new subnet on the PXE VLAN for use with DHCP
 - Create a VSI for use with PXE booting a Bare Metal [NO OS](https://cloud.ibm.com/docs/bare-metal?topic=bare-metal-bm-no-os) Server
 - Run or create Ansible Playbooks to:
    - Update the OS
    - Install and configure Dnsmasq and PXE
    - Download Ubuntu Server ISO
    - Copy ISO netboot tools in to the `tftpboot` directory
    - Copy Ubuntu ISO files to PXE Dir
    - Update the dnsmasq configuration 
    - Configure DHCP settings 
 - Create a support ticket to have the VSIs private IP set as the DHCP helper address on the VLAN. 
 - Deploy a NO OS server and test if it properly PXE boots.

## Todos
 - [x] Switch from DHCP and TFTP to dnsmasq as it has built in TFTP support and is more robust (Ansible)
 - [x] Look at recursive copy [issue](https://github.com/greyhoundforty/ibm_pxe_terraform/issues/3)


## Configure environment
 - Install Terraform and the IBM Terraform provider using this [guide](https://cloud.ibm.com/docs/terraform?topic=terraform-getting-started#install).
 - Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 
 - Create a `credentials.tfvars` file or set [environmental variables](https://ibm-cloud.github.io/tf-ibm-docs/v0.17.1/) for IBM authentication.