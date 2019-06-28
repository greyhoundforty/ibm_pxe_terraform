---
- hosts: vm_instances
  become: true
  tasks:
    - name: Update apt packages
      apt: upgrade=yes update_cache=yes
      when: ansible_facts['os_family'] == "Debian"
    - name: "Install PXE TFTP utilities"
      apt:
        name: "{{ packages }}"
      vars:
        packages:
        - apache2
        - dnsmasq
    - name: "Create directory structure"
      file:
        path: "{{ with_items }}"
        state: directory
        mode: '0755'
        with_items:
          - /mnt/iso-storage
          - /var/lib/tftpboot/
          - /var/www/html/server/bionic
    - name: "Grab Ubuntu ISO for testing PXE boot"
      get_url:
        url: http://releases.ubuntu.com/16.04/ubuntu-16.04.6-server-amd64.iso
        dest: /tmp/ubuntu-16.04.6-server-amd64.iso
        mode: '0644'
      register: get_ubuntu_iso
    - debug: 
        msg="ISO already downloaded"
      when: get_ubuntu_iso|changed
    - name: Mount Ubuntu server ISO read-only
      mount: 
        path: /mnt/iso-storage
        src: /tmp/ubuntu-16.04.6-server-amd64.iso
        fstype: iso9660
        opts: ro,loop
        state: mounted
    - name: "Sync netboot files"
      copy:
        src: /mnt/iso-storage/install/netboot/
        dest: /var/lib/tftpboot/
        remote_src: yes
    - name: "Sync web files"
      copy:
        src: /mnt/iso-storage/
        dest: /var/www/html/server/bionic/
        remote_src: yes
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