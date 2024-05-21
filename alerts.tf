
//Custom Project Alerts

resource "mongodbatlas_alert_configuration" "ENCRYPTION_AT_REST_KMS_NETWORK_ACCESS_DENIED" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "ENCRYPTION_AT_REST_KMS_NETWORK_ACCESS_DENIED"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }
  depends_on = [mongodbatlas_project.atlas_project, mongodbatlas_encryption_at_rest.encryption]
}

resource "mongodbatlas_alert_configuration" "HOST_DOWN" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "HOST_DOWN"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "HOST_HAS_INDEX_SUGGESTIONS" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "HOST_HAS_INDEX_SUGGESTIONS"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "CLUSTER_MONGOS_IS_MISSING" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "CLUSTER_MONGOS_IS_MISSING"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "NO_PRIMARY" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "NO_PRIMARY"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }
  depends_on = [mongodbatlas_project.atlas_project]
}


resource "mongodbatlas_alert_configuration" "NORMALIZED_SYSTEM_CPU_USER" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "NORMALIZED_SYSTEM_CPU_USER"
    operator    = var.mongo_cluster_metric_threshold.operator
    threshold   = var.mongo_cluster_metric_threshold.threshold
    units       = var.mongo_cluster_metric_threshold.units
    mode        = var.mongo_cluster_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "NORMALIZED_SYSTEM_CPU_STEAL_90" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "NORMALIZED_SYSTEM_CPU_USER"
    operator    = var.mongo_cluster_metric_threshold.operator
    threshold   = var.mongo_cluster_metric_threshold.threshold
    units       = var.mongo_cluster_metric_threshold.units
    mode        = var.mongo_cluster_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "NORMALIZED_SYSTEM_CPU_STEAL_60" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "NORMALIZED_SYSTEM_CPU_STEAL"
    operator    = var.mongo_cluster_metric_threshold.operator
    threshold   = var.mongo_cluster_metric_threshold.threshold
    units       = var.mongo_cluster_metric_threshold.units
    mode        = var.mongo_cluster_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "QUERY_TARGETING_SCANNED_OBJECTS_PER_RETURNED" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "QUERY_TARGETING_SCANNED_OBJECTS_PER_RETURNED"
    operator    = var.mongo_query_metric_threshold.operator
    threshold   = var.mongo_query_metric_threshold.threshold
    units       = var.mongo_query_metric_threshold.units
    mode        = var.mongo_query_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}


resource "mongodbatlas_alert_configuration" "DISK_PARTITION_SPACE_USED_DATA" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "DISK_PARTITION_SPACE_USED_DATA"
    operator    = var.mongo_cluster_metric_threshold.operator
    threshold   = var.mongo_cluster_metric_threshold.threshold
    units       = var.mongo_cluster_metric_threshold.units
    mode        = var.mongo_cluster_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "DISK_PARTITION_READ_IOPS_DATA" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "DISK_PARTITION_READ_IOPS_DATA"
    operator    = var.mongo_cluster_metric_threshold.operator
    threshold   = var.mongo_cluster_metric_threshold.threshold
    units       = var.mongo_cluster_metric_threshold.units
    mode        = var.mongo_cluster_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}

resource "mongodbatlas_alert_configuration" "CONNECTIONS_PERCENT" {
  project_id = mongodbatlas_project.atlas_project.id
  event_type = "OUTSIDE_METRIC_THRESHOLD"
  enabled    = true

  notification {
    type_name                   = var.mongo_alarms_notifications_settings.notification
    interval_min                = var.mongo_alarms_notifications_settings.interval_min
    delay_min                   = var.mongo_alarms_notifications_settings.delay_min
    microsoft_teams_webhook_url = data.aws_secretsmanager_secret_version.webhook_url.secret_string
  }

  metric_threshold_config {
    metric_name = "CONNECTIONS_PERCENT"
    operator    = var.mongo_cluster_metric_threshold.operator
    threshold   = var.mongo_cluster_metric_threshold.threshold
    units       = var.mongo_cluster_metric_threshold.units
    mode        = var.mongo_cluster_metric_threshold.mode
  }
  depends_on = [mongodbatlas_project.atlas_project]
}


