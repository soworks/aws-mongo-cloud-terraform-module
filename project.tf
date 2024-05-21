# -----------------------------------
#   || MongoAtlas Project Setup ||
# -----------------------------------

resource "mongodbatlas_project" "atlas_project" {
  name                         = upper(replace("${var.mongodbatlas_project_name}_${var.env_name}", "-", "_")) # Project name should be upper case and underscores
  org_id                       = var.mongodb_org_id
  with_default_alerts_settings = false

  dynamic "teams" {
    for_each = local.resolved_existing_teams
    content {
      team_id    = teams.key
      role_names = teams.value.role_names
    }
  }
  dynamic "limits" {
    for_each = local.resolved_project_limits
    content {
      name  = limits.value.name
      value = limits.value.value
    }
  }
  is_collect_database_specifics_statistics_enabled = var.database_specifics_statistics
  is_data_explorer_enabled                         = var.data_explorer
  is_extended_storage_sizes_enabled                = var.extended_storage_sizes
  is_performance_advisor_enabled                   = var.performance_advisor
  is_realtime_performance_panel_enabled            = var.realtime_performance_panel
  is_schema_advisor_enabled                        = var.schema_advisor

}

resource "mongodbatlas_project_ip_access_list" "cidr_block_entry" {
  for_each   = local.resolved_cidr_block_entries
  project_id = mongodbatlas_project.atlas_project.id
  cidr_block = each.key
  comment    = each.value.comment
}

# ---------------------------
# Atlas Database Audit
# ---------------------------
resource "mongodbatlas_auditing" "auditing" {
  count                       = var.mongodbatlas_auditing ? 1 : 0
  project_id                  = mongodbatlas_project.atlas_project.id
  audit_filter                = "{ 'atype': 'authenticate', 'param': {   'user': 'auditAdmin',   'db': 'admin',   'mechanism': 'SCRAM-SHA-1' }}"
  audit_authorization_success = false
  enabled                     = var.mongodbatlas_auditing
}

# ---------------------------
# Maintenance Window Management
# ---------------------------
resource "mongodbatlas_maintenance_window" "maintenance_window" {
  project_id  = mongodbatlas_project.atlas_project.id
  day_of_week = var.maintenance_window_day_of_week
  hour_of_day = var.maintenance_window_hour_of_day
}
