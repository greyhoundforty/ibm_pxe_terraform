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
              domain=cdetesting.local
              dhcp-range=${first_usable_ip},${last_usable_ip},${subnet_netmask},1h
              dhcp-option=3,${subnet_gw}
              dhcp-option=6,${subnet_gw}
              server=8.8.8.8
              dhcp-boot=/boot/pxelinux.0,pxeserver,${pxe_ip}
              enable-tftp
              tftp-root=/var/lib/tftpboot/
