# Existing RG + VNet
data "azurerm_resource_group" "target" {
  name = "Idea2.0"
}

data "azurerm_virtual_network" "vnet" {
  name                = "idea2.0Vnet"
  resource_group_name = data.azurerm_resource_group.target.name
}

# If VNet already has at least one subnet, use it.
# Otherwise, create a new subnet automatically and use that.
locals {
  use_existing_subnet = length(data.azurerm_virtual_network.vnet.subnets) > 0
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_subnet" "auto" {
  count = local.use_existing_subnet ? 0 : 1
  name  = "auto-${random_string.suffix.result}"

  resource_group_name  = data.azurerm_resource_group.target.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name

  address_prefixes = [cidrsubnet(data.azurerm_virtual_network.vnet.address_space[0], 1, 0)]
}

resource "azurerm_data_factory" "myDataFactory" {
  name                = "myDataFactory"
  location            = data.azurerm_resource_group.target.location
  resource_group_name = data.azurerm_resource_group.target.name

  sku {
    name = "Standard"
  }
}