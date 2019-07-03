# IBM Cloud PXE server (WIP)
Example of how to deploy a PXE host to help with the installation and initial deployment of Bare Metal [NO OS](https://cloud.ibm.com/docs/bare-metal?topic=bare-metal-bm-no-os) servers on the IBM Cloud. This allows for greater automation for customers that need to load a custom operating system on to a NO OS server. 

## The code in this example will:
 - Create a new VLAN for PXE deployment environment
 - Create a new subnet on the PXE VLAN for use with DHCP
 - Create a VSI for use with PXE booting a Bare Metal [NO OS](https://cloud.ibm.com/docs/bare-metal?topic=bare-metal-bm-no-os) Server
 - Run Ansible Playbooks to:
    - Update the OS
    - Install and configure Dnsmasq and PXE
    - Download Ubuntu Server ISO
    - Copy ISO netboot tools in to the `tftpboot` directory
    - Copy Ubuntu ISO files to PXE Dir
    - Update the dnsmasq configuration 
    - Configure DHCP settings 
 - Create a support ticket to have the VSIs private IP set as the DHCP helper address on the appropriate VLAN. 
 - Deploy a NO OS server on to the PXE server VLAN.

## Configure environment
To use this code you will need to make sure you have met the following requirements:

 - Terraform* and the IBM Terraform provider plugin installed - [guide](https://cloud.ibm.com/docs/terraform?topic=terraform-getting-started#install).
 - Ansible installed - [guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 
 - Updated the `credentials.tfvars.tpl` file with your IBM Cloud API key, SoftLayer username, and SoftLayer API Key.

> * If you already have Terraform v0.12 installed you will need to use a differnet machine or downgrade. The IBM Cloud Provider plugin only supports pre-v0.12 Terraform versions. 

## Testing the code

### Grab the repositor

```
git clone https://github.com/greyhoundforty/ibm_pxe_terraform.git
cd ibm_pxe_terraform
```

### Update credentials file

Copy the credentials template file and update it with your IBM Cloud details. More information about provider variables can be found [here](https://ibm-cloud.github.io/tf-ibm-docs/#authentication).

```
cp credentials.tfvars.tpl credentials.tfvars
vi/nano credentials.tfvars
```

### Initialize Terraform
Run the `terraform init` command to initialize the directory containing your Terraform files. 

```
terraform init
```

### Create the initial Terraform plan
The [plan](https://www.terraform.io/docs/commands/plan.html) command is used create an execution plan based on your Terraform files. 

```
terraform plan -var-file='./credentials.tfvars' -out project.tfplan
```

If everything is configured correctly you should see a bunch of output that looks like this:

```
  + ibm_compute_vm_instance.pxe_server
      id:                           <computed>
      block_storage_ids.#:          <computed>
      cores:                        <computed>
      datacenter:                   "wdc06"
      disks.#:                      <computed>
      domain:                       "cdetesting.com"
      file_storage_ids.#:           <computed>
      flavor_key_name:              "B1_8X16X100"
      hostname:                     "pxewdc06"
      hourly_billing:               "true"
      ip_address_id:                <computed>
      ip_address_id_private:        <computed>
      ipv4_address:                 <computed>
      ipv4_address_private:         <computed>
      ipv6_address:                 <computed>
      ipv6_address_id:              <computed>
      ipv6_enabled:                 "false"
      ipv6_static_enabled:          "false"
      local_disk:                   "false"
      memory:                       <computed>
      network_speed:                "1000"
      os_reference_code:            "UBUNTU_16_64"
      private_interface_id:         <computed>
      private_network_only:         "false"
      private_security_group_ids.#: <computed>
      private_subnet:               <computed>
      private_subnet_id:            <computed>
      private_vlan_id:              "0"
      public_bandwidth_limited:     <computed>
      public_bandwidth_unlimited:   "false"
      public_interface_id:          <computed>
      public_ipv6_subnet:           <computed>
      public_ipv6_subnet_id:        <computed>
      public_security_group_ids.#:  <computed>
      public_subnet:                <computed>
      public_subnet_id:             <computed>
      public_vlan_id:               <computed>
      secondary_ip_addresses.#:     <computed>
      ssh_key_ids.#:                "1"
      ssh_key_ids.1133649:          "1133649"
      tags.#:                       "3"
      tags.1677294981:              "wdc06"
      tags.2205552373:              "pxe-server"
      tags.3988618716:              "ryantiffany"
      user_metadata:                "#cloud-config\napt_update: true\nusers:\n  - name: ryan\n    groups: [ sudo ]\n    sudo: [ \"ALL=(ALL) NOPASSWD:ALL\" ]\n    shell: /bin/bash\n    ssh-authorized-keys:\n    - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4lY4YcpVi2KaH2xMzXCRbJ0S/PztQMlUHoCKTIjWEybREpfntD0hhaaKIUw8UUR4324mA5JVpBzlGyMusKFlVmbaMjkfNZpUyqR4OW4zcTEXXnowbD6FZpfMejPJl9WLD5Pmt88TM4NfqOhsqmInXj3X6iBpBdZ94bWLfFrNOYNqCInL3t91Ks3DHbD8MbwMJ4itPb6m3RAEkvVc1ImEo9NVpMKuSbyjbiQTuDHsLajCGOI6tf4IgZw2MIq9QnfklhxHfswTfjpN3hVhJgAtSwjbicXzn0gKGoxQvqK0mLtzMMe0/12pspT7b7Pwg6Boygat1PS1CryHJmCfdy0xf ryan@Ryans-MacBook-Pro.local'\n    - 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxcx9wbVCHjxyJxZwho+o2TnvkBPk/IifoJfAcLbgtO7QAI8EWB2p4eDtlPo2zAoTfSPS9TiCUUffBcXwpFLKLR2vvht5+Me4pozqTl9fDbWOWmfNWN8dLHR1oruZm+kYLL0CPt99KHXtYQnxsYfFzu37ZVOrzT6MNzfk7aYwojDOni6jt9F+HjdXr+6d4QUjBVRmdUAUcxUjgCh1efj7Q6NAXOFUP/oAHRJsfmYKLH3YvsjFy7OT67DSDoMEldHHOL9EWmQcQtOLY+H/HJYl+87jINJ4AZB5D4Tozi7QLN6tvoIhTPZHwWAyg4HasE3VFjwBlIunEnFkmMxolJfLp ryan@hyperion.local'\npackages:\n    - python\n    - python-apt\n    - python3-apt\nfinal_message: \"The system is finally up, after $UPTIME seconds\"\noutput: {all: '| tee -a /var/log/cloud-init-output.log'}"
      wait_time_minutes:            "90"

  + ibm_network_vlan.pxe_vlan
      id:                           <computed>
      child_resource_count:         <computed>
      datacenter:                   "wdc06"
      name:                         "pxe_vlan_wdc06"
      router_hostname:              "bcr01a.wdc06"
      softlayer_managed:            <computed>
      subnets.#:                    <computed>
      type:                         "PRIVATE"
      vlan_number:                  <computed>

  + ibm_subnet.dhcp_subnet
      id:                           <computed>
      capacity:                     "8"
      ip_version:                   "4"
      notes:                        "dhcp testing subnet"
      private:                      "true"
      subnet_cidr:                  <computed>
      type:                         "Portable"
      vlan_id:                      "0"
```

### Deploy your infrastructure
With our plan created we can now get to the task at hand of actual deploying infrastructure assets. 

```
terraform apply project.tfplan
```

### Todo
 - [ ] Generacize the `install.yml` file to not set up the `ryan` user. Should probably be something like `deployer`.
 - [ ] Write about how to update `install.yml` with any ssh-key. 
 - [ ] Update inventory file creation to use new ansible user (a.k.a. deployer)
 - [ ] Remove any `ryan` related tags, settings
 - [ ] Add other DCs to datacenter map
