resource "azurerm_resource_group" "rg" {
  for_each = var.config
  location = var.location
  name     = each.value.rgname
}

module "vnet" {
  depends_on = [
    azurerm_resource_group.rg
  ]
  source                  = "./vnet"
  location                = var.location
  config                  = var.config
}
module "vm" {
  depends_on = [
    azurerm_resource_group.rg,
    module.vnet
  ]
  source         = "./vm"
  config         = var.config
  admin_password = var.admin_password
  admin_username = var.admin_username
  location       = var.location
  subnet_ids     = module.vnet.subnet_ids
  vmsize         = var.vmsize
}