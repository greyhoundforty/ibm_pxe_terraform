```
# Create python ticket script
// resource "local_file" "python_ticket" {
//   depends_on = ["local_file.ansible_hosts"]

//   content = <<EOF
// import SoftLayer
// client = SoftLayer.Client()
// def createTicket(self):
//     current_user = client.call('SoftLayer_Account', 'getCurrentUser')
//     body = "This is a test automation ticket for a PXE boot process. Just need to see if the script picks up variables. Private IP = ${ibm_compute_vm_instance.pxe_server.ipv4_address_private} and VLAN = ${ibm_network_vlan.pxe_vlan.id}. Ticket can be closed."
//     # http://sldn.softlayer.com/reference/datatypes/SoftLayer_Ticket
//     new_ticket = {
//         'subjectId': 1061,
//         'assignedUserId': current_user['id'],
//         'title': 'Set DHCP helper IP for PXE boot - Test API ticket',
//         'priority': 4
//     }
//     # parameter list is from, need to be in order http://sldn.softlayer.com/reference/services/softlayer_ticket/createStandardTicket
//     created_ticket = client.call('SoftLayer_Ticket', 'createStandardTicket', 
//         new_ticket, body, serverId, serverPass, None, None, None, 'HARDWARE')
//     pp(created_ticket)

// EOF

//   filename = "${path.cwd}/createPXETicket.py"
// }

// curl -u $SL_USER:$SL_APIKEY -X POST -H "Accept: */*" -H "Accept-Encoding: gzip, deflate, compress" -d '{"parameters": [{"subjectId": 1021}, "Content of the ticket goes here"]}' 'https://api.softlayer.com/rest/v3.1/SoftLayer_Ticket/createStandardTicket.json'


# Call python to create ticket. I think this will be replaced by curl at some point 
// resource "null_resource" "create_ticket" {
//   depends_on = ["local_file.python_ticket"]

//   provisioner "local-exec" {
//     command = "/usr/local/bin/python3 ${path.cwd}/createPXETicket.py"
//   }
// }
```