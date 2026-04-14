resource "azurerm_network_interface" "vm" {
  name                = "nic-${var.project_name}-${var.environment}-${var.location_short}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-${var.project_name}-${var.environment}-${var.location_short}-001"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  tags                            = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "osdisk-${var.project_name}-${var.environment}-${var.location_short}-001"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(local.cloud_init)
}

# --- VM auto-shutdown (kosten besparing buiten werktijden) ---

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm" {
  virtual_machine_id    = azurerm_linux_virtual_machine.vm.id
  location              = var.location
  enabled               = true
  daily_recurrence_time = "1800"
  timezone              = "W. Europe Standard Time"

  notification_settings {
    enabled = false
  }

  tags = var.tags
}

# --- Cloud-init for Docker + Docker Compose + SSH hardening ---

locals {
  cloud_init = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true

    packages:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - ufw
      - unattended-upgrades
      - iptables-persistent

    # SSH hardening (conform LIVIQ SECURE-ARCHITECTURE-BASELINE)
    write_files:
      - path: /etc/ssh/sshd_config.d/hardening.conf
        content: |
          PermitRootLogin no
          PasswordAuthentication no
          X11Forwarding no
          MaxAuthTries 3
          AllowUsers ${var.admin_username}
        permissions: '0644'

      - path: /etc/sysctl.d/99-hardening.conf
        content: |
          # Reverse path filtering (anti-spoofing)
          net.ipv4.conf.all.rp_filter = 1
          net.ipv4.conf.default.rp_filter = 1
          # ICMP hardening
          net.ipv4.icmp_echo_ignore_broadcasts = 1
          net.ipv4.icmp_ignore_bogus_error_responses = 1
          # Log martian packets
          net.ipv4.conf.all.log_martians = 1
          # Symlink/hardlink protection
          fs.protected_symlinks = 1
          fs.protected_hardlinks = 1
          # Kernel pointer restriction
          kernel.kptr_restrict = 2
          kernel.dmesg_restrict = 1
        permissions: '0644'

    runcmd:
      # Apply kernel hardening
      - sysctl --system

      # Restart SSH with hardened config
      - systemctl restart sshd

      # Install Docker
      - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
      - apt-get update
      - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
      - systemctl enable docker
      - systemctl start docker
      - usermod -aG docker ${var.admin_username}

      # Configure firewall
      - ufw default deny incoming
      - ufw default allow outgoing
      - ufw allow 22/tcp
      - ufw allow 80/tcp
      - ufw allow 443/tcp
      - ufw --force enable

      # Docker egress firewall — whitelist-based outbound traffic
      - iptables -I DOCKER-USER -i br-+ -o eth0 -j DROP
      - iptables -I DOCKER-USER -i br-+ -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      - iptables -I DOCKER-USER -i br-+ -o eth0 -p tcp --dport 443 -j ACCEPT
      - iptables -I DOCKER-USER -i br-+ -o eth0 -p tcp --dport 80 -j ACCEPT
      - iptables -I DOCKER-USER -i br-+ -o eth0 -p udp --dport 53 -j ACCEPT
      - iptables -I DOCKER-USER -i br-+ -o eth0 -p tcp --dport 53 -j ACCEPT
      - netfilter-persistent save

      # Enable automatic security updates
      - systemctl enable unattended-upgrades
      - systemctl start unattended-upgrades
  EOF
}

# --- Key Vault access for the VM's managed identity ---

resource "azurerm_role_assignment" "vm_keyvault_reader" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}
