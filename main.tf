# Pull in existing SSH key for use with Ansible
data "ibm_compute_ssh_key" "deploymentKey" {
  label = "ryan_tycho"
}

# Create a random name for our VLAN. This is mainly used in testing and will be removed at some point
resource "random_id" "name" {
  byte_length = 4
}

# Create our PXE Vlan 
resource "ibm_network_vlan" "pxe_vlan" {
  name            = "pxe_vlan_${var.datacenter["us-east2"]}"
  datacenter      = "${var.datacenter["us-east2"]}"
  type            = "PRIVATE"
  router_hostname = "bcr01a.${var.datacenter["us-east2"]}"

  timeouts {
    delete = "30m"
  }
}

# Create a subnet for DHCP server 
resource "ibm_subnet" "dhcp_subnet" {
  type       = "Portable"
  private    = true
  ip_version = 4
  capacity   = 8
  vlan_id    = "${ibm_network_vlan.pxe_vlan.id}"
  notes      = "dhcp testing subnet"
}

# Create our VSI PXE instance 
resource "ibm_compute_vm_instance" "pxe_server" {
  hostname             = "pxe${var.datacenter["us-east2"]}"
  domain               = "${var.domain}"
  os_reference_code    = "${var.os_reference_code["u16"]}"
  datacenter           = "${var.datacenter["us-east2"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  user_metadata        = "${file("install.yml")}"
  flavor_key_name      = "${var.flavor_key_name["pxe"]}"
  tags                 = ["ryantiffany", "pxe-server", "${var.datacenter["us-east2"]}"]
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.deploymentKey.id}"]
  private_vlan_id      = "${ibm_network_vlan.pxe_vlan.id}"
  local_disk           = false
}

# Create a temp inventory file to run Playbooks against 
resource "local_file" "ansible_hosts" {
  content = <<EOF
[vm_instances]
pxe ansible_host=${ibm_compute_vm_instance.pxe_server.ipv4_address} 

EOF

  filename = "${path.cwd}/Hosts/inventory.env"
}

# Create our dnsmasq.conf file for PXE server
resource "local_file" "dnsmasq_config" {
  depends_on = ["local_file.ansible_hosts"]

  content = <<EOF
---
  - hosts: vm_instances
    become: true
    tasks:
    - name: "Update dnsmasq conf"
      blockinfile:
          backup: yes
          path: /etc/dnsmasq.conf
          block: |
              interface=eth0,lo
              bind-interfaces
              listen-address=${ibm_compute_vm_instance.pxe_server.ipv4_address_private},127.0.0.1
              domain=cdetesting.local
              dhcp-range=${cidrhost(ibm_subnet.dhcp_subnet.subnet_cidr, 2)},${cidrhost(ibm_subnet.dhcp_subnet.subnet_cidr, 6)},${cidrnetmask(ibm_subnet.dhcp_subnet.subnet_cidr)},1h
              dhcp-option=3,${cidrhost(ibm_subnet.dhcp_subnet.subnet_cidr, 1)}
              dhcp-option=6,8.8.8.8,4.2.2.2
              server=8.8.8.8
              dhcp-boot=/pxelinux.0,pxeserver,${ibm_compute_vm_instance.pxe_server.ipv4_address_private}
              enable-tftp
              tftp-root=/var/lib/tftpboot/
EOF

 filename = "${path.cwd}/Playbooks/dnsmasq.yml"
}

resource "local_file" "curl_body" {
  depends_on = ["local_file.ansible_hosts"]

  content = <<EOF
{
  "parameters": [
    {
      "subjectId": 1061,
      "title": "Set DHCP helper IP for PXE boot"
    },
    "Please set the DHCP helper IP on VLAN ${ibm_network_vlan.pxe_vlan.id} in the ${var.datacenter["us-east2"]} DC to ${ibm_compute_vm_instance.pxe_server.ipv4_address_private}. If the VLAN already has a DHCP helper IP please remove it and replace it with the one listed in this ticket."
  ]
}
EOF

  filename = "${path.cwd}/ticket.json"
}

resource "null_resource" "create_ticket" {
  depends_on = ["local_file.curl_body"]

  provisioner "local-exec" {
    command = "curl -u ${var.ibm_sl_username}:${var.ibm_sl_api_key} -X POST -H 'Accept: */*' -H 'Accept-Encoding: gzip, deflate, compress' -d @${path.cwd}/ticket.json 'https://api.softlayer.com/rest/v3.1/SoftLayer_Ticket/createStandardTicket.json'"
  }
}

# Run ansible playbook to install and configure TFTP/DHCP/Webroot
resource "null_resource" "run_playbook" {
  // depends_on = ["null_resource.create_ticket"]
    depends_on = ["local_file.curl_body"]
  provisioner "local-exec" {
    command = "ansible-playbook -i Hosts/inventory.env Playbooks/server-config.yml"
  }
}

resource "ibm_compute_bare_metal" "no_os" {
  # Mandatory fields
  package_key_name = "DUAL_E52600_V4_12_DRIVES"
  process_key_name = "INTEL_INTEL_XEON_E52620_V4_2_10"
  memory           = 64
  os_key_name      = "OS_NO_OPERATING_SYSTEM"
  hostname         = "no-os"
  domain           = "${var.domain}"
  datacenter       = "${var.datacenter["us-east2"]}"
  network_speed    = 10000
  public_bandwidth = 500
  disk_key_names   = ["HARD_DRIVE_800GB_SSD", "HARD_DRIVE_800GB_SSD", "HARD_DRIVE_800GB_SSD"]
  hourly_billing   = false

  # Optional fields
  private_network_only = false
  unbonded_network     = true

  public_vlan_id  = "${ibm_compute_vm_instance.pxe_server.public_vlan_id}"
  private_vlan_id = "${ibm_network_vlan.pxe_vlan.id}"

  tags = [
    "pxe-test",
    "ryantiffany",
  ]

  redundant_power_supply = true
}

