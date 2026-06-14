resource "azurerm_container_group" "matchmaking" {
  name                = "${var.prefix}-matchmaking"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  ip_address_type = "Private"
  subnet_ids      = [var.subnet_service_id]

  container {
    name   = "matchmaking-api"
    image  = "${var.acr_login_server}/matchmaking-api:${var.matchmaking_tag}"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 3001
      protocol = "TCP"
    }

    environment_variables = {
      PORT = "3001"
    }
  }

  image_registry_credential {
    server   = var.acr_login_server
    username = var.acr_admin_username
    password = var.acr_admin_password
  }
}

resource "azurerm_container_group" "dashboard" {
  name                = "${var.prefix}-dashboard"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  ip_address_type = "Private"
  subnet_ids      = [var.subnet_service_id]

  container {
    name   = "player-dashboard"
    image  = "${var.acr_login_server}/player-dashboard:${var.dashboard_tag}"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      PORT = "3000"
    }
  }

  image_registry_credential {
    server   = var.acr_login_server
    username = var.acr_admin_username
    password = var.acr_admin_password
  }
}

resource "azurerm_container_group" "telemetry" {
  name                = "${var.prefix}-telemetry"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"

  ip_address_type = "Private"
  subnet_ids      = [var.subnet_service_id]

  container {
    name   = "telemetry-collector"
    image  = "${var.acr_login_server}/telemetry-collector:${var.telemetry_tag}"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {
      PORT = "8080"
    }
  }

  image_registry_credential {
    server   = var.acr_login_server
    username = var.acr_admin_username
    password = var.acr_admin_password
  }
}
