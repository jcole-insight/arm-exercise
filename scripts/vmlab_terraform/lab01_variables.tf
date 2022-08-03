
variable "vmName" {
  description = "Name of VM"
  type = string
}
variable "location" {
    description = "location of resources"
    type = string
}


variable "subnetPrefix" {
    type = string
}

variable "privateIpAddressIP" {
  type = string
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
        