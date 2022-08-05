vm = {
  vm1 = {
    name      = "tflab1"
    privateIP = "10.0.0.5"
  }
  vm2 = {
    name      = "tflab2"
    privateIP = "10.0.0.6"
  }
}
nicIP = [
  "10.0.0.5",
  "10.0.0.6"
]
rgName             = "TFLabGroup"
vnetName           = "tflab-vnet"
nsgName            = "tflab-nsg"
subnetName         = "tflab-subnet"
location           = "East US"
subnetPrefix       = "10.0.0.0/24"
privateIpAddressIP = ["10.0.0.5", "10.0.0.6"]
DiskType           = "StandardSSD_LRS"
adminUsername      = "lab-user"
adminPassword      = "LabPassword123"