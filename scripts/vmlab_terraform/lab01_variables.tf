
variable "vm" {
  description = "Name of VM"
  type        = map(object({
    name = string
    privateIP = string
  }))
}
variable "nicIP" {
  description = "Name of VM"
  type        = list(any)
}
variable "location" {
  description = "location of resources"
  type        = string
}
variable "rgName" {
  description = "Name of RG"
  type        = string
}
variable "subnetName" {
  description = "Name of Subnet"
  type        = string
}
variable "vnetName" {
  description = "Name of VNet"
  type        = string
}
variable "nsgName" {
  description = "Name of NSG"
  type        = string
}
variable "subnetPrefix" {
  type = string
}
variable "privateIpAddressIP" {
  type = list(string)
}

variable "DiskType" {
  type = string
}
variable "adminPassword" {
  type = string
}
variable "adminUsername" {
  type = string
}
        