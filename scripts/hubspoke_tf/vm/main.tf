resource "azurerm_public_ip" "pip" {
  for_each               = var.config
  name                = each.value.pipname
  resource_group_name = each.value.rgname
  location            = var.location
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "nic" {
  for_each            = var.config
  name                = each.value.nicname
  resource_group_name = each.value.rgname
  location            = var.location

  ip_configuration {
    name                          = "ipconfig-${each.key}"
    subnet_id                     = var.subnet_ids[each.key]
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.vmprivateip
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = var.config
  name                = each.value.vmname
  resource_group_name = each.value.rgname
  location            = var.location
  size                = var.vmsize
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = "ReadWrite"
    disk_size_gb         = 127
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }
}
resource "azurerm_managed_disk" "LabDataDisk" {
  for_each             = var.config
  name                 = "${each.value.vmname}-disk1"
  location             = var.location
  resource_group_name  = each.value.rgname
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "LabDiskAttach" {
  for_each           = var.config
  managed_disk_id    = azurerm_managed_disk.LabDataDisk[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[each.key].id
  lun                = "0"
  caching            = "ReadWrite"
}