output "nameservers" {
  value = azurerm_dns_zone.aks-public-dns.name_servers
}