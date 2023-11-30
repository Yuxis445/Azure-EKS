locals {
  env = "${var.environment}" == "" ? "" : "${var.environment}-"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${local.env}-aks"
  location            = var.rg_location
  resource_group_name = var.rg_name
  dns_prefix          = "testing-aks"
  
#   kubernetes_version  = "1.26.3"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
    zones = [ 1 ]
    vnet_subnet_id = var.vnet_id
    # pod_subnet_id                = var.vnet_subnet_id

    
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr = "10.0.2.0/24"
    dns_service_ip     = "10.0.2.10"

  }

  tags = {
    environment = "Demo"
    Terraform = "True"
  }
}