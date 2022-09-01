variable "location" {}
variable "config" {
  type = map(any)
}
variable "vmsize" {}
variable "admin_password" {}
variable "admin_username" {}
variable "subnet_ids" {
  type = map(any)
}