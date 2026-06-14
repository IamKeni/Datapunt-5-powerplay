resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}${var.purpose}sa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Versleuteling en veiligheid
  min_tls_version = "TLS1_2"
}

resource "azurerm_storage_share" "share" {
  name               = "${var.purpose}share"
  storage_account_id = azurerm_storage_account.sa.id
  quota              = 100
}
