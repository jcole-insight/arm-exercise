variable "resource_group_name" {
  description = "name of resource group"
  type = string
}

variable "location" {
    description = "location of resources"
    type = string
}

variable "vm_name" {
  description = "Name of VM"
  type = string
}

variable "security_group_rules" {
  type = string
}

variable "subnet_prefix" {
    type = string
}

variable "private_ip_address" {
  type = string
}