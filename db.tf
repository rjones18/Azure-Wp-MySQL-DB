data "azurerm_key_vault" "example" {
  name                = "rj-key"
  resource_group_name = "test-grp"
}

data "azurerm_key_vault_secret" "mysql_admin_login" {
  name         = "WP-USER-NAME"
  key_vault_id = data.azurerm_key_vault.example.id
}

data "azurerm_key_vault_secret" "mysql_admin_password" {
  name         = "WP-DB-PASSWORD"
  key_vault_id = data.azurerm_key_vault.example.id
}

data "azurerm_virtual_network" "example" {
  name                = "project-network"
  resource_group_name = "project-network-rg"
}

# Reference an existing VNet subnet
data "azurerm_subnet" "example" {
  name                 = "data-subnet-1"
  virtual_network_name = "project-network"
  resource_group_name  = "project-network-rg"
}


resource "azurerm_private_dns_zone" "example" {
  name                = "rj.mysql.database.azure.com"
  resource_group_name = var.rg
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = data.azurerm_virtual_network.example.id
  resource_group_name   = var.rg
}

resource "azurerm_mysql_flexible_server" "example" {
  name                   = "rj-wp-fs"
  resource_group_name    = var.rg
  location               = var.location
  administrator_login    = data.azurerm_key_vault_secret.mysql_admin_login.value
  administrator_password = data.azurerm_key_vault_secret.mysql_admin_password.value
  backup_retention_days  = 7
  delegated_subnet_id    = data.azurerm_subnet.example.id
  private_dns_zone_id    = azurerm_private_dns_zone.example.id
  sku_name               = "GP_Standard_D2ds_v4"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}

resource "azurerm_mysql_flexible_database" "example" {
  name                = "wordpress"
  resource_group_name = var.rg
  server_name         = azurerm_mysql_flexible_server.example.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}