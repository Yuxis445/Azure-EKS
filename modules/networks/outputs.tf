output "vnet_subnet_prefix" {
  value = azurerm_subnet.aks-public-subnet.address_prefixes[0]
}

output "vnet_subnet_id" {
  value = azurerm_subnet.aks-public-subnet.id
}