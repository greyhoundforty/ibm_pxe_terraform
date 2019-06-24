# ibm_pxe_terraform
Example of how to deploy a PXE VSI. The code in this example will:

 - [x] Create a new VLAN for PXE deployment environment
 - [x] Create a VSI for use with PXE booting a Bare Metal [NO OS](https://cloud.ibm.com/docs/bare-metal?topic=bare-metal-bm-no-os) Server
 - [ ] Create Ansible Playbook to:
    - [x] Update the OS
    - [x] Install and configure TFTP and PXE
    - [x] Download ISO
    - [x] Copy ISO netboot tools in to the `tftpboot` directory
    - [x] Copy Ubuntu ISO files to PXE Dir
    - [ ] Configure the `pxelinux` configuration file
    - [ ] Configure DHCP settings 
 - [x] Create a support ticket to have the VSIs private IP set as the DHCP helper address on the router. 

[Install PXE on Ubuntu 16](https://www.ostechnix.com/how-to-install-pxe-server-on-ubuntu-16-04/)
