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
  name            = "pxe_vlan_${random_id.name.hex}"
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
  tags                 = ["ryantiffany", "pxe-server", "${var.datacenter["us-south2"]}"]
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

# Create python ticket script
resource "local_file" "python_ticket" {
  depends_on = ["local_file.ansible_hosts"]
  content = <<EOF
import SoftLayer
client = SoftLayer.Client()
def createTicket(self):
    current_user = client.call('SoftLayer_Account', 'getCurrentUser')
    body = "This is a test automation ticket for a PXE boot process. Just need to see if the script picks up variables. Private IP = ${ibm_compute_vm_instance.pxe_server.ipv4_address_private} and VLAN = ${ibm_network_vlan.pxe_vlan.id}. Ticket can be closed."
    # http://sldn.softlayer.com/reference/datatypes/SoftLayer_Ticket
    new_ticket = {
        'subjectId': 1061,
        'assignedUserId': current_user['id'],
        'title': 'Set DHCP helper IP for PXE boot - Test API ticket',
        'priority': 4
    }
    # parameter list is from, need to be in order http://sldn.softlayer.com/reference/services/softlayer_ticket/createStandardTicket
    created_ticket = client.call('SoftLayer_Ticket', 'createStandardTicket', 
        new_ticket, body, serverId, serverPass, None, None, None, 'HARDWARE')
    pp(created_ticket)

EOF

  filename = "${path.cwd}/createPXETicket.py"
}

# Call python to create ticket. I think this will be replaced by curl at some point 
resource "null_resource" "create_ticket" {
  depends_on = ["local_file.python_ticket"]
  provisioner "local-exec" {
    command = "/usr/local/bin/python3 ${path.cwd}/createPXETicket.py"
  }
}

# Run ansible playbook to install and configure TFTP/DHCP/Webroot
resource "null_resource" "run_playbook" {
  depends_on = ["local_file.python_ticket"]
  provisioner "local-exec" {
    command = "ansible-playbook -i Hosts/inventory.env Playbooks/server-config.yml"
  }
}
