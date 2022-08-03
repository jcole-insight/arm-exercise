terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.1"
    }
  }
}

provider "azurerm" {
  features {}
  # Configuration options
}

resource "azurerm_resource_group" "LabGroup" {
  name     = "${var.vmName}Group"
  location = var.location
}

resource "azurerm_network_security_group" "LabNSG" {
  name                = "${var.vmName}-nsg"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location
  security_rule {
      name                       = "rdp"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range    = "3389"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "LabVNet" {
  name                = "${var.vmName}-vnet"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location
  depends_on = [
    azurerm_network_security_group.LabNSG
  ]
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "LabSubnet" {
  name                 = "${var.vmName}-subnet"
  resource_group_name  = azurerm_resource_group.LabGroup.name
  virtual_network_name = azurerm_virtual_network.LabVNet.name
  address_prefixes     = [var.subnetPrefix]
}
resource "azurerm_network_interface" "LabNIC" {
  name                = "${var.vmName}-nic"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location

  ip_configuration {
    name                          = "${var.vmName}-ipconfig1"
    subnet_id                     = azurerm_subnet.LabSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.privateIpAddressIP
  }
}
resource "azurerm_subnet_network_security_group_association" "LabNsgAsc" {
  subnet_id                 = azurerm_subnet.LabSubnet.id
  network_security_group_id = azurerm_network_security_group.LabNSG.id
}

resource "azurerm_windows_virtual_machine" "LabVM" {
  name                = var.vmName
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.adminUsername
  admin_password      = var.adminPassword
  network_interface_ids = [
    azurerm_network_interface.LabNIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}