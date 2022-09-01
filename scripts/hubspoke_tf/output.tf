# output "rg_names" {
#   value = tomap({
#     for name in keys(var.vnet) : name => azurerm_resource_group.rg[name].name
#   })
# }
# output "subnet_ids" {
#   value = module.vnet.subnet_ids
# }