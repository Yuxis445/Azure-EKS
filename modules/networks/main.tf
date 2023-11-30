locals {
  env = "${var.environment}" == "" ? "" : "${var.environment}-"
}

resource "azurerm_network_security_group" "aks-sg" {
  name                = "${local.env}security-group"
  location            = var.rg_location
  resource_group_name = var.rg_name
}

resource "azurerm_virtual_network" "aks-network" {
  name                = "${local.env}network"
  address_space       = ["${var.network_cidr}"]
  location            = var.rg_location
  resource_group_name = var.rg_name

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "aks-public-subnet" {
  name                 = "${local.env}public-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.aks-network.name
  address_prefixes     = ["10.0.1.0/24"]

  # delegation {
  #   name = "delegation"

  #   service_delegation {
  #     name    = "Microsoft.ContainerInstance/containerGroups"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #   }
  # }
}