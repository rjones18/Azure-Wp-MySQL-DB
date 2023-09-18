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

resource "azurerm_mysql_server" "example" {
  name                = "rj-wpserver"
  location            = var.location
  resource_group_name = var.rg

  administrator_login          = data.azurerm_key_vault_secret.mysql_admin_login.value
  administrator_login_password = data.azurerm_key_vault_secret.mysql_admin_password.value
  

  sku_name   = "GP_Gen5_2" # General Purpose, Gen 5, 2 vCores
  storage_mb = 5120       
  version    = "8.0"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled = false # Disabling public access for security
  ssl_enforcement_enabled       = false  # Ensure SSL is used
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_mysql_database" "example_db" {
  name                = "wordpress"   # Name your database
  resource_group_name = azurerm_mysql_server.example.resource_group_name
  server_name         = azurerm_mysql_server.example.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Reference an existing VNet subnet
data "azurerm_subnet" "example" {
  name                 = "data-subnet-1"
  virtual_network_name = "project-network"
  resource_group_name  = "project-network-rg"
}

# Create a private endpoint for the MySQL server
resource "azurerm_private_endpoint" "example" {
  name                = "rj-wpserver-mysql-private-endpoint"
  location            = var.location
  resource_group_name = "wordpress-website-resources"
  subnet_id           = data.azurerm_subnet.example.id

  private_service_connection {
    name                           = "example-mysql-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mysql_server.example.id
    subresource_names              = ["mysqlServer"]
  }
}


