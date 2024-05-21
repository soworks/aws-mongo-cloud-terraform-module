# -----------------------------------------
#   || MongoAtlas Cluster Backup Policy ||
# -----------------------------------------

resource "mongodbatlas_cloud_backup_schedule" "main" {
  count        = var.cloud_backup ? 1 : 0
  project_id   = mongodbatlas_project.atlas_project.id
  cluster_name = mongodbatlas_cluster.cluster.name

  reference_hour_of_day    = var.backup_config.reference_hour_of_day
  reference_minute_of_hour = var.backup_config.reference_minute_of_hour
  restore_window_days      = var.backup_config.restore_window_days

  dynamic "policy_item_hourly" {
    for_each = lookup(var.backup_config, "policy_item_hourly", null) != null ? [var.backup_config.policy_item_hourly] : []
    content {
      frequency_interval = policy_item_hourly.value.frequency_interval
      retention_unit     = policy_item_hourly.value.retention_unit
      retention_value    = policy_item_hourly.value.retention_value
    }
  }

  dynamic "policy_item_daily" {
    for_each = lookup(var.backup_config, "policy_item_daily", null) != null ? [var.backup_config.policy_item_daily] : []
    content {
      frequency_interval = policy_item_daily.value.frequency_interval
      retention_unit     = policy_item_daily.value.retention_unit
      retention_value    = policy_item_daily.value.retention_value
    }
  }

  dynamic "policy_item_weekly" {
    for_each = lookup(var.backup_config, "policy_item_weekly", null) != null ? [var.backup_config.policy_item_weekly] : []
    content {
      frequency_interval = policy_item_weekly.value.frequency_interval
      retention_unit     = policy_item_weekly.value.retention_unit
      retention_value    = policy_item_weekly.value.retention_value
    }
  }

  dynamic "policy_item_monthly" {
    for_each = lookup(var.backup_config, "policy_item_monthly", null) != null ? [var.backup_config.policy_item_monthly] : []
    content {
      frequency_interval = policy_item_monthly.value.frequency_interval
      retention_unit     = policy_item_monthly.value.retention_unit
      retention_value    = policy_item_monthly.value.retention_value
    }
  }
}
