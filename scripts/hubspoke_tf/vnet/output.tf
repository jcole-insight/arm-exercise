output "subnet_ids" {
  value = tomap({
    for id in keys(var.config) : id => azurerm_subnet.subnet[id].id
  })
}