# ------------------------------------------------
#    || AWS Resources for Encryption at Rest ||
# ------------------------------------------------

# ---------------------
# AWS KMS Key
# ---------------------

resource "aws_kms_key" "mongoatlas_encryption_kms_key" {
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  description              = var.description
  key_usage                = var.key_usage
  customer_master_key_spec = var.customer_master_key_spec
  tags                     = local.tags
}

resource "aws_kms_key_policy" "mongoatlas_encryption_kms_key_policy" {
  key_id = aws_kms_key.mongoatlas_encryption_kms_key.id
  policy = data.aws_iam_policy_document.mongoatlas_encryption_kms_key_policy_document.json
}

resource "aws_kms_alias" "mongoatlas_encryption_kms_alias" {
  name_prefix   = "alias/${var.component}-data-store-key"
  target_key_id = join("", aws_kms_key.mongoatlas_encryption_kms_key[*].id)
}

# ---------------------
# AWS <> Atlas Role
# ---------------------

resource "aws_iam_role" "mongoatlas_encryption_kms_role" {
  name_prefix        = "mongodb_atlas_setup_role"
  assume_role_policy = data.aws_iam_policy_document.mongo_role_policy_document.json
}

resource "aws_iam_role_policy" "mongoatlas_encryption_policy" {
  name_prefix = "mongodb_atlas_encryption_policy"
  role        = aws_iam_role.mongoatlas_encryption_kms_role.id
  policy      = data.aws_iam_policy_document.encryption_policy_document.json
}


# --------------------------------------------------
#  || MongoAtlas Resources for Encryption at Rest ||
# --------------------------------------------------

resource "time_sleep" "wait_30_seconds" {
  depends_on = [mongodbatlas_cloud_provider_access_authorization.auth_role,
    mongodbatlas_cloud_provider_access_setup.setup_only,
    aws_kms_key.mongoatlas_encryption_kms_key,
  aws_iam_role_policy.mongoatlas_encryption_policy, aws_iam_role.mongoatlas_encryption_kms_role]

  create_duration = "30s"
}

resource "mongodbatlas_encryption_at_rest" "encryption" {
  project_id = mongodbatlas_project.atlas_project.id

  aws_kms_config {
    enabled                = true
    customer_master_key_id = aws_kms_key.mongoatlas_encryption_kms_key.id
    region                 = var.atlas_region
    role_id                = mongodbatlas_cloud_provider_access_authorization.auth_role.role_id
  }

  depends_on = [time_sleep.wait_30_seconds]

}

resource "mongodbatlas_cloud_provider_access_setup" "setup_only" {
  project_id    = mongodbatlas_project.atlas_project.id
  provider_name = var.atlas_encryption_cloud_provider
}

resource "mongodbatlas_cloud_provider_access_authorization" "auth_role" {
  project_id = mongodbatlas_project.atlas_project.id
  role_id    = mongodbatlas_cloud_provider_access_setup.setup_only.role_id

  aws {
    iam_assumed_role_arn = aws_iam_role.mongoatlas_encryption_kms_role.arn
  }
}
