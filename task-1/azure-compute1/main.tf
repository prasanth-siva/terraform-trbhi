module "os" {
  source       = "./os"
  vm_os_simple = var.vm_os_simple
}

data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

data "template_file" "cloudconfig" {
  template = "${file("${path.module}/monitoring.tpl")}"
}

resource "azurerm_virtual_machine" "vm-linux" {
  count				= var.instances
  name                          = "${var.vm_environment}-vmLinux-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location
  availability_set_id           = azurerm_availability_set.vm.id
  vm_size                       = var.vm_size
  network_interface_ids         = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination

 storage_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

  storage_os_disk {
    name              = "osdisk-${var.vm_environment}-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  os_profile {
    computer_name  = "trbhi-machine"
    admin_username = "trbhi-admin"
    admin_password = "P@ssW0rd1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_environment}-avset"
  resource_group_name          = data.azurerm_resource_group.vm.name
  location                     = data.azurerm_resource_group.vm.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags                         = var.tags
}

resource "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = "${var.vm_environment}-public_ip-${count.index}"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location
  allocation_method   = var.allocation_method
  tags                = var.tags
}

resource "azurerm_application_security_group" "common-appsg" {
  name                = "common-appsg"
  location            = data.azurerm_resource_group.vm.location
  resource_group_name = data.azurerm_resource_group.vm.name

  tags = var.tags
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_environment}-nsg"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = data.azurerm_resource_group.vm.location

  tags = var.tags
}

resource "azurerm_network_security_rule" "vm" {
  name                        = "allow-all_in_all"
  resource_group_name         = data.azurerm_resource_group.vm.name
  description                 = "Allow connections from all locations"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.vm.name
}

#resource "azurerm_network_security_rule" "vm1" {
#  name                        = "allow-ssh-from-vm"
#  resource_group_name         = data.azurerm_resource_group.vm.name
#  description                 = "Allow connections from vm1"
#  priority                    = 100
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_range      = 22
#  source_application_security_group_ids = [azurerm_application_security_group.common-appsg.id]
#  #source_address_prefix       = "*"
#  destination_address_prefix  = "*"
#  network_security_group_name = azurerm_network_security_group.vm.name
#}

resource "azurerm_network_interface" "vm" {
  count                         = var.instances
  name                          = "${var.vm_environment}-networkic-${count.index}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = data.azurerm_resource_group.vm.location

  ip_configuration {
    name                          = "${var.vm_environment}-ip-${count.index}"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.vm.*.id, count.index) 
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "test" {
  count                     = var.instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}

