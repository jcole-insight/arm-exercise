resource "azurerm_virtual_network" "vnet" {
  for_each            = var.config
  name                = each.value.vnetname
  address_space       = each.value.vnet_address_space
  location            = var.location
  resource_group_name = each.value.rgname
}

resource "azurerm_subnet" "subnet" {
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  for_each             = var.config
  name                 = each.value.subnetname
  resource_group_name  = each.value.rgname
  virtual_network_name = each.value.vnetname
  address_prefixes     = each.value.subnet_address_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.config
  name                = each.value.nsgname
  location            = var.location
  resource_group_name = each.value.rgname

  # security_rule {
  #   name                       = "allow_rdp"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = 3389
  #   destination_port_range     = 3389
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
  security_rule {
    name                       = "rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
  name                        = "ICMP"
  priority                    = 3000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = 8
  destination_port_range      = 0
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_associate" {
  for_each                  = var.config
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  subnet_id                 = azurerm_subnet.subnet[each.key].id
}

resource "azurerm_virtual_network_peering" "hubtospoke" {
  name                      = "hubtospoke"
  resource_group_name       = lookup(var.config["hub"], "rgname", null)
  virtual_network_name      = azurerm_virtual_network.vnet["hub"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["spoke"].id
}

resource "azurerm_virtual_network_peering" "spoketohub" {
  name                      = "spoketohub"
  resource_group_name       = lookup(var.config["spoke"], "rgname", null)
  virtual_network_name      = azurerm_virtual_network.vnet["spoke"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["hub"].id
}