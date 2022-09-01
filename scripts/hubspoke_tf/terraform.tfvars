
config = {
  hub = {
    rgname = "hub-rg"

    vnetname = "hub-vnet"
    vnet_address_space = ["10.0.0.0/16"]

    subnetname      = "hub-subnet"
    subnet_address_prefixes = ["10.0.0.0/24"]

    vmname = "hub-vm"
    vmprivateip = "10.0.0.5"
    nicname = "hub-nic"
    pipname = "hub-pip"

    nsgname = "hub-nsg"
  }
  spoke = {
    rgname = "spoke-rg"

    vnetname = "spoke-vnet"
    vnet_address_space = ["192.168.0.0/16"]

    subnetname      = "spoke-subnet"
    subnet_address_prefixes = ["192.168.0.0/24"]

    vmname = "spoke-vm"
    vmprivateip = "192.168.0.5"
    nicname = "spoke-nic"
    pipname = "spoke-pip"

    nsgname = "spoke-nsg"
  }
}
vmsize                  = "Standard_B2s"
location                = "eastus"
admin_username          = "azureuser"
admin_password          = "Azure@12345!"