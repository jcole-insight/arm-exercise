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
  name     = "TFLabGroup"
  location = "West US"
}

resource "azurerm_network_security_group" "LabNSG" {
  name                = "tf-nsg1"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = azurerm_resource_group.LabGroup.location
}

resource "azurerm_virtual_network" "LabVNet" {
  name                = "tflab-vnet"
  resource_group_name = azurerm_resource_group.LabGroup.name
  location            = azurerm_resource_group.LabGroup.location
  depends_on = [
    azurerm_network_security_group.LabNSG
  ]
  address_space       = ["10.0.0.0/16"]

  subnet = {
    address_prefix = "10.0.0.0/24"
    name           = "tflab-subnet1"
  }
}
resource "azurerm_subnet" "LabSubnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}