terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# -------------------------------------------------------
# Storage Account voor centrale log-opslag (Opdracht 4)
# -------------------------------------------------------
resource "azurerm_storage_account" "logs" {
  name                     = "${var.prefix}logs${random_integer.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# -------------------------------------------------------
# Alert 1: VM CPU boven 80% — vroeg signaal voor overbelasting
# -------------------------------------------------------
resource "azurerm_monitor_metric_alert" "vm_cpu_high" {
  name                = "${var.prefix}-vm-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "CPU-gebruik boven 80% — mogelijke overbelasting van gameserver"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }
}

# -------------------------------------------------------
# Alert 2: Log Storage Account bijna vol (>80%)
# -------------------------------------------------------
resource "azurerm_monitor_metric_alert" "storage_capacity" {
  name                = "${var.prefix}-log-storage-full"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_storage_account.logs.id]
  description         = "Log storage account is meer dan 80% vol"
  severity            = 2
  frequency           = "PT1H"
  window_size         = "PT6H"

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "UsedCapacity"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85899345920
  }
}
