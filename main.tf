resource "azurerm_resource_group" "abele-rg" {
  name     = "abele-resources"
  location = "East US"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "abele-vn" {
  name                = "abele-network"
  resource_group_name = azurerm_resource_group.abele-rg.name
  location            = azurerm_resource_group.abele-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "abele-subnet" {
  name                 = "abele-subnet"
  resource_group_name  = azurerm_resource_group.abele-rg.name
  virtual_network_name = azurerm_virtual_network.abele-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "abele-nsg" {
  name                = "abele-nsg"
  resource_group_name = azurerm_resource_group.abele-rg.name
  location            = azurerm_resource_group.abele-rg.location

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "abele-dev-rule" {
  name                        = "abele-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.abele-rg.name
  network_security_group_name = azurerm_network_security_group.abele-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "sga" {
  subnet_id                 = azurerm_subnet.abele-subnet.id
  network_security_group_id = azurerm_network_security_group.abele-nsg.id
}

resource "azurerm_public_ip" "abele-ip" {
  name                = "abele-ip"
  resource_group_name = azurerm_resource_group.abele-rg.name
  location            = azurerm_resource_group.abele-rg.location
  sku                 = "Basic"
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "abele-nic" {
  name                = "abele-nic"
  location            = azurerm_resource_group.abele-rg.location
  resource_group_name = azurerm_resource_group.abele-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.abele-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.abele-ip.id
  }
  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "abele-vm" {
  name                = "abele-vm"
  resource_group_name = azurerm_resource_group.abele-rg.name
  location            = azurerm_resource_group.abele-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
  azurerm_network_interface.abele-nic.id]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/abeleazurekey.pub")
  }

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

  provisioner "local-exec" {
      command = templatefile("${var.host_os}-ssh-script.tpl", {
          hostname     = self.public_ip_address,
          user         = "adminuser",
          identityfile = "~/.ssh/abeleazurekey"
      })
      interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "abele-ip-data" {
    name = azurerm_public_ip.abele-ip.name
    resource_group_name = azurerm_resource_group.abele-rg.name
}

output "public_ip_address" {
  value       = "${azurerm_linux_virtual_machine.abele-vm.name}: ${data.azurerm_public_ip.abele-ip-data.ip_address}"
}