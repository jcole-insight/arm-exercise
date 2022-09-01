# variable "vnet" {
#   description = "Vnet Attributes"
#   type        = map(object({
#     name = string
#     vnet_address_space = list(string)
#   }))
# }
variable "location" {}
variable "config" {
  type = map(any)
}