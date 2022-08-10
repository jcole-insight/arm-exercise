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
  name     = var.rgName
  location = var.location
}

resource "azurerm_network_security_group" "LabNSG" {
  name                = var.nsgName
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location
  security_rule {
    name                       = "rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "LabVNet" {
  name                = "${var.vnetName}"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location
  depends_on = [
    azurerm_network_security_group.LabNSG
  ]
  address_space = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "LabSubnet" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.LabGroup.name
  virtual_network_name = azurerm_virtual_network.LabVNet.name
  address_prefixes     = [var.subnetPrefix]
}
resource "azurerm_network_interface" "LabNIC" {
  for_each            = var.vm
  name                = "${each.value.name}-nic"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = azurerm_subnet.LabSubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.privateIP
  }
}
resource "azurerm_subnet_network_security_group_association" "LabNsgAsc" {
  subnet_id                 = azurerm_subnet.LabSubnet.id
  network_security_group_id = azurerm_network_security_group.LabNSG.id
}

resource "azurerm_windows_virtual_machine" "LabVM" {
  for_each            = var.vm
  name                = each.value.name
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = var.adminUsername
  admin_password      = var.adminPassword
  network_interface_ids = [
    azurerm_network_interface.LabNIC[each.key].id,
  ]

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    create_option        = "FromImage"
    disk_size_gb         = 127
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}
resource "azurerm_managed_disk" "LabDataDisk" {
  for_each             = var.vm
  name                 = "${each.value.name}-disk1"
  location             = azurerm_resource_group.LabGroup.location
  resource_group_name  = azurerm_resource_group.LabGroup.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "LabDiskAttach" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = azurerm_virtual_machine.example.id
  lun                = "10"
  caching            = "ReadWrite"
}