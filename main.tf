# Pull in existing SSH key for use with Ansible
data "ibm_compute_ssh_key" "deploymentKey" {
  label = "ryan_tycho"
}

# Create our PXE Vlan 
resource "ibm_network_vlan" "pxe_vlan" {
  name            = "pxe_vlan"
  datacenter      = "${var.datacenter["us-south2"]}"
  type            = "PRIVATE"
  router_hostname = "bcr01a.${var.datacenter["us-south2"]}"
}

# Create our VSI PXE instance 
resource "ibm_compute_vm_instance" "pxe_server" {
  hostname             = "pxe"
  domain               = "${var.domain}"
  os_reference_code    = "${var.os_reference_code["u16"]}"
  datacenter           = "${var.datacenter["us-south2"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  user_metadata        = "${file("install.yml")}"
  flavor_key_name      = "${var.flavor_key_name["pxe"]}"
  local_disk           = "${var.localdisk}"
  tags                 = ["ryantiffany", "pxe-server", "${var.datacenter["us-south2"]}"]
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.deploymentKey.id}"]
  private_vlan_id      = "${ibm_network_vlan.pxe_vlan.id}"
}

# Create a temp inventory file to run Playbooks against 
resource "local_file" "ansible_hosts" {
  content = <<EOF
[vm_instances]
pxe ansible_host=${ibm_compute_vm_instance.pxe_server.ipv4_address} 

EOF

  filename = "${path.cwd}/inventory.env"
}

// # Curl data to send for ticket 
// resource "local_file" "ticket_body" {
//   content = <<EOF

// EOF

//   filename = "${path.cwd}/ticket_contents.json"
// }

# Create Ticket to have helper IP set. May be better to use Terraform template file to genrate ticket and post it via Curl. Set to echo for now during testing. 
resource "null_resource" "create_ticket" {
  provisioner "local-exec" {
    command = "echo slcli ticket create --title 'Set DHCP helper IP --subject-id 1061 --body 'Please set a DHCP helper IP of ${ibm_compute_vm_instance.pxe_server.ipv4_address_private} on VLAN ${ibm_network_vlan.pxe_vlan.id}'"
  }
}
