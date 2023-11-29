resource "azurerm_resource_group" "my-rg" {
  name     = "resource-test"
  location = var.region
}

module "vpc" {

  source = "./modules/networks"

  rg_name = azurerm_resource_group.my-rg.name
  rg_location = azurerm_resource_group.my-rg.location
  region = var.region
  environment = var.environment
  network_cidr = var.network_cidr

}