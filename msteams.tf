module "msteams_notification" {
  #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash - this is annoying for private modules"
  source = "./../"

  name           = "${local.cluster_name}-notifications"
  sns_topic_name = "${local.cluster_name}-notifications"
  teams_webhook  = data.aws_secretsmanager_secret_version.webhook_url.secret_string
}
