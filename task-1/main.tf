provider "azurerm" {
  features {}
}

#terraform {
# backend "azurerm" {
#   resource_group_name  = "StorageAccount-ResourceGroup"
#   storage_account_name = "abcd1234"
#   container_name       = "tfstate"
#   key                  = "${var.environment}.terraform.tfstate"
# }
#}

resource "azurerm_resource_group" "vm" {
  name     = "${var.environment}-vm"
  location = "East US"
}

module "network" {
  source              = "./azure-network1"
  resource_group_name = azurerm_resource_group.vm.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet
  subnet_names	      = var.subnet_names
}

module "linuxservers" {
  source              = "./azure-compute1"
  resource_group_name = azurerm_resource_group.vm.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["ubuntuserver"] 
  vm_size	      = var.staging["ubuntu"]
  vnet_subnet_id      = module.network.vnet_subnets[0]
}

