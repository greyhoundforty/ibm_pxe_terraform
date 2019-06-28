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
 - Create a support ticket to have the VSIs private IP set as the DHCP helper address on the router. 
 - Deploy a NO OS server and test if it properly PXE boots.

## Todos
 - [x] Switch from DHCP and TFTP to dnsmasq as it has built in TFTP support and is more robust (Ansible)
 - [ ] Look at recursive copy [issue]()
