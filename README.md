# ibm_pxe_terraform
Example of how to deploy a PXE VSI. The code in this example will:

 - [ ] Create a new VLAN for PXE deployment environment
 - [ ] Create a VSI for use with PXE booting a Bare Metal [NO OS](https://cloud.ibm.com/docs/bare-metal?topic=bare-metal-bm-no-os) Server
 - [ ] Install and configure TFTP/PXE service on the instance using Ansible 
 - [ ] Pull down some common ISOs
 - [ ] Create a support ticket to have the VSIs private IP set as the DHCP helper address on the router. 

