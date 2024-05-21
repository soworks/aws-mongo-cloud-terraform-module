# -----------------------------------
#   || MongoAtlas Cluster ||
# -----------------------------------

resource "mongodbatlas_cluster" "cluster" {
  project_id                     = mongodbatlas_project.atlas_project.id
  name                           = local.cluster_name
  cluster_type                   = "REPLICASET"
  mongo_db_major_version         = var.mongo_db_major_version
  disk_size_gb                   = var.disk_size_gb
  termination_protection_enabled = local.termination_protection

  # ----------------------------
  # || Cluster tier scaling  ||
  # ----------------------------

  auto_scaling_compute_enabled                    = var.auto_scaling_compute_enabled
  auto_scaling_compute_scale_down_enabled         = var.auto_scaling_compute_enabled == false ? false : var.auto_scaling_compute_scale_down_enabled
  auto_scaling_disk_gb_enabled                    = var.auto_scaling_disk_gb_enabled
  provider_auto_scaling_compute_min_instance_size = var.provider_auto_scaling_compute_min_instance_size
  provider_auto_scaling_compute_max_instance_size = var.provider_auto_scaling_compute_max_instance_size
  provider_name                                   = var.atlas_cloud_provider
  encryption_at_rest_provider                     = var.atlas_encryption_cloud_provider
  provider_region_name                            = var.atlas_region
  provider_instance_size_name                     = var.atlas_instance_type
  provider_disk_iops                              = var.provider_disk_iops
  provider_volume_type                            = var.volume_type
  cloud_backup                                    = var.cloud_backup
  pit_enabled                                     = var.pit_enabled


  # ------------------------------
  # || Cluster replication specs||
  # ------------------------------
  replication_specs {
    num_shards = local.number_of_shards
    regions_config {
      region_name     = var.atlas_region
      electable_nodes = var.electable_nodes
      priority        = var.priority
      read_only_nodes = var.read_only_nodes
    }
  }

  dynamic "tags" {
    for_each = local.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }

  depends_on = [mongodbatlas_project.atlas_project, mongodbatlas_privatelink_endpoint_service.service, mongodbatlas_encryption_at_rest.encryption]
}

# ------------------------------
# || Database Users ||
# ------------------------------

resource "random_password" "master_user_password" {
  length           = 32
  special          = true
  lower            = true
  upper            = true
  override_special = "!#*"
}

resource "random_password" "ro_user_password" {
  length           = 24
  special          = true
  lower            = true
  upper            = true
  override_special = "!#*"
}

resource "random_string" "random_suffix" {
  length  = 16
  special = false
  upper   = true
}

# Master User
resource "aws_secretsmanager_secret" "mongo_password" {
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - can't do auto rotation here"
  #checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK - not required for now"
  recovery_window_in_days = 0
  name                    = "${var.env_name}/atlas-mongodb-credentials/${var.mongodbatlas_project_name}/${var.database_master_user}/${random_string.random_suffix.result}"
  tags = {
    Name = "${var.database_master_user}-passwd"
  }
  depends_on = [random_string.random_suffix]
}

resource "aws_secretsmanager_secret_version" "mongo_password" {
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - can't do auto rotation here"
  #checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK - not required for now"
  secret_id     = aws_secretsmanager_secret.mongo_password.id
  secret_string = random_password.master_user_password.result
}

# Read Only User
resource "aws_secretsmanager_secret" "mongo_ro_password" {
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - can't do auto rotation here"
  #checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK - not required for now"
  recovery_window_in_days = 0
  name                    = "${var.env_name}/atlas-mongodb-credentials/${var.mongodbatlas_project_name}/ro_database_user/${random_string.random_suffix.result}"
  tags = {
    Name = "ro_database_user-passwd"
  }
  depends_on = [random_string.random_suffix]
}

resource "aws_secretsmanager_secret_version" "mongo_ro_password" {
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - can't do auto rotation here"
  #checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK - not required for now"
  secret_id     = aws_secretsmanager_secret.mongo_ro_password.id
  secret_string = random_password.ro_user_password.result
}

# URI needed by the application to connect to the cluster
resource "aws_secretsmanager_secret" "mongodb_uri" {
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - can't do auto rotation here"
  #checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK - not required for now"
  recovery_window_in_days = 0
  name                    = "${var.env_name}/atlas-mongodb-credentials/${var.mongodbatlas_project_name}/mongodb-uri"
  tags = {
    Name = "${var.mongodbatlas_project_name}-mongodb-uri"
  }
  depends_on = [random_string.random_suffix]
}

resource "aws_secretsmanager_secret_version" "mongodb_uri" {
  #checkov:skip=CKV2_AWS_57: "Ensure Secrets Manager secrets should have automatic rotation enabled - can't do auto rotation here"
  #checkov:skip=CKV_AWS_149: "Ensure that Secrets Manager secret is encrypted using KMS CMK - not required for now"
  secret_id = aws_secretsmanager_secret.mongodb_uri.id
  secret_string = join("", [
    "mongodb+srv://",
    "${var.database_master_user}:${random_password.master_user_password.result}@",
    replace(local.endpoint_connection_string, "mongodb+srv://", ""),
    "${var.mongodb_uri_suffix}"
  ])

  depends_on = [
    mongodbatlas_privatelink_endpoint_service.service,
    mongodbatlas_cluster.cluster
  ]
}

resource "mongodbatlas_database_user" "database_master_user" {
  username           = var.database_master_user
  password           = random_password.master_user_password.result
  project_id         = mongodbatlas_project.atlas_project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
  scopes {
    name = local.cluster_name
    type = "CLUSTER"
  }
  depends_on = [mongodbatlas_cluster.cluster, random_password.master_user_password]
}

resource "mongodbatlas_database_user" "ro_database_user" {
  username           = "ro_dbuser"
  password           = random_password.ro_user_password.result
  project_id         = mongodbatlas_project.atlas_project.id
  auth_database_name = "admin"

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }
  scopes {
    name = local.cluster_name
    type = "CLUSTER"
  }
  depends_on = [mongodbatlas_cluster.cluster, random_password.ro_user_password]
}
