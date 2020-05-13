# terraform-azure-compute

A Terraform module containing common configurations for an Azure to create linux vm. 

## Terraform versions

Terraform 0.12. Submit pull-requests to `master` branch.

## Provider versions

provider azurerm v2.9.0

## Usage example

```hcl
provider "azurerm" {
  features {}
}

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
  cloudconfig_file    = "${path.module}/monitoring.tpl"
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["ubuntuserver"] 
  vm_size   	      = var.staging["ubuntu"]
  vnet_subnet_id      = module.network.vnet_subnets[0]
}
```
