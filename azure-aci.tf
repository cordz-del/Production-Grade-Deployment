# azure-aci.tf
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "aiResourceGroup"
  location = "East US"
}

resource "azurerm_container_group" "aci" {
  name                = "aiContainerGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "ai-service"
    image  = "your-dockerhub-username/ai-service:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }
  }

  ip_address {
    type            = "Public"
    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
}
