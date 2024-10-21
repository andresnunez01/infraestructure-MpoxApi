#Construir Resource Group

resource "azurerm_resource_group" "IN_RG" {
  name     = var.resource_group
  location = var.location
}

#Crear Virtual Network

resource "azurerm_virtual_network" "IN_VNET" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.IN_RG.name
  location            = var.location
  address_space       = ["10.123.0.0/16"]
}

# Crear Subnet

resource "azurerm_subnet" "IN_SUBNET" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.IN_RG.name
  virtual_network_name = azurerm_virtual_network.IN_VNET.name
  address_prefixes     = ["10.123.1.0/24"]
}

#Crear Security Groups

resource "azurerm_network_security_group" "IN_SG" {
  name                = var.security_name
  location            = var.location
  resource_group_name = azurerm_resource_group.IN_RG.name

  security_rule {
    name                       = "ssh-allow"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http-allow"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https-allow"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "IN_SGA" {
  subnet_id                 = azurerm_subnet.IN_SUBNET.id
  network_security_group_id = azurerm_network_security_group.IN_SG.id
}

#Crear IP Publica

resource "azurerm_public_ip" "IN_IP" {
  name                = var.ip_name
  resource_group_name = azurerm_resource_group.IN_RG.name
  location            = var.location
  allocation_method   = "Dynamic"
}

#Crear Network Interface Card

resource "azurerm_network_interface" "IN_NIC" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.IN_RG.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.IN_SUBNET.id
    public_ip_address_id          = azurerm_public_ip.IN_IP.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Maquina virtual

resource "azurerm_linux_virtual_machine" "IN_VM" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.IN_RG.name
  location              = var.location
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.IN_NIC.id]
  custom_data           = filebase64("${path.module}/scripts/docker-install.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("./keys/Mpox_server.pub")
  }
  provisioner "file" {
    source      = "./containers/docker-compose.yml"
    destination = "/home/${var.admin_username}/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = file("./keys/Mpox_server")
      host        = self.public_ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su -c 'mkdir -p /home/${var.admin_username}'",
      "sudo su -c 'mkdir -p /volumes/nginx/html'",
      "sudo su -c 'mkdir -p /volumes/nginx/certs'",
      "sudo su -c 'mkdir -p /volumes/nginx/vhostd'",
      "sudo su -c 'mkdir -p /volumes/mongo/data'",
      "sudo su -c 'chmod 770 /volumes/mongo/data'",
      "sudo su -c 'touch /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MONGO_URL=${var.MONGO_URL}\" >> /home/${var.admin_username}/.env '",
      "sudo su -c 'echo \"PORT=${var.PORT}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MONGO_DB=${var.MONGO_DB}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MAILER_ACCESS_TOKEN=${var.MAILER_ACCESS_TOKEN}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MAPBOX_ACCESS_TOKEN=${var.MAPBOX_ACCESS_TOKEN}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MAILER_SERVICE=${var.MAILER_SERVICE}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MAILER_EMAIL=${var.MAILER_EMAIL}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MONGO_INITDB_ROOT_USERNAME=${var.MONGO_INITDB_ROOT_USERNAME}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"MONGO_INITDB_ROOT_PASSWORD=${var.MONGO_INITDB_ROOT_PASSWORD}\" >> /home/${var.admin_username}/.env'",
      "sudo su -c 'echo \"DOMAIN=${var.DOMAIN}\" >> /home/${var.admin_username}/.env'",
    ]
    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = file("./keys/Mpox_server")
      host        = self.public_ip_address
    }
  }
}

resource "time_sleep" "wait_120_seconds" {
  depends_on      = [azurerm_linux_virtual_machine.IN_VM]
  create_duration = "120s"
}

resource "null_resource" "init_docker" {
  depends_on = [time_sleep.wait_120_seconds]
  provisioner "remote-exec" {
    inline = ["sudo su -c 'docker-compose up -d'"]
    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = file("./keys/Mpox_server")
      host        = azurerm_linux_virtual_machine.IN_VM.public_ip_address
    }
  }
}