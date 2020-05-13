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

data "template_file" "cloudconfig" {
  template = "${file("${var.cloudconfig_file}")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
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
  vm_size	      = var.staging["ubuntu"]
  vnet_subnet_id      = module.network.vnet_subnets[0]
}

