# -----------------------------------
#    || Module Data Resources ||
# -----------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-vpc"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-vpc-private-*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

//Encryption
data "aws_iam_policy_document" "mongo_role_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [mongodbatlas_cloud_provider_access_setup.setup_only.aws_config[0].atlas_aws_account_arn]
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "sts:ExternalId"
      values   = [mongodbatlas_cloud_provider_access_setup.setup_only.aws_config[0].atlas_assumed_role_external_id]
    }

  }
}

data "aws_iam_policy_document" "mongoatlas_encryption_kms_key_policy_document" {
  statement {
    sid       = "Allow administration of the key"
    effect    = "Allow"
    resources = [aws_kms_key.mongoatlas_encryption_kms_key.arn]

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow use of the key"
    effect    = "Allow"
    resources = [aws_kms_key.mongoatlas_encryption_kms_key.arn]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    effect    = "Allow"
    resources = [aws_kms_key.mongoatlas_encryption_kms_key.arn]

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "encryption_policy_document" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey*"
    ]
    resources = [aws_kms_key.mongoatlas_encryption_kms_key.arn]
  }
}

//Alerts
data "aws_secretsmanager_secret" "webhook_url" {
  name = "notifications_channel_webhook_url"
}

data "aws_secretsmanager_secret_version" "webhook_url" {
  secret_id = data.aws_secretsmanager_secret.webhook_url.id
}
