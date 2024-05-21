# ------------------------------------------------
#     || MongoDB Altas TF module outputs ||
# ------------------------------------------------

# ---------------------------
# Project Outputs
# ---------------------------
output "project_id" {
  description = "Atlas Project ID"
  value       = mongodbatlas_project.atlas_project.id
}

# ---------------------------
# Network Outputs
# ---------------------------
output "private_link_id" {
  description = "Atlas Project Prviate Link ID"
  value       = mongodbatlas_privatelink_endpoint.endpoint.private_link_id
}
output "endpoint_service_name" {
  description = "Atlas Project endpoint Service Name"
  value       = mongodbatlas_privatelink_endpoint.endpoint.endpoint_service_name
}
output "interface_endpoint_id" {
  description = "Atlas Project interface Endpoint ID"
  value       = mongodbatlas_privatelink_endpoint_service.service.interface_endpoint_id
}
output "vpc_endpoint_id" {
  description = "Atlas Project VPC Endpoint ID for Atlas Project"
  value       = aws_vpc_endpoint.mongo_vpc_endpoint.id
}

output "mongo_vpc_endpoint_sg_id" {
  description = "Atlas Project VPC Endpoint Security Group ID"
  value       = aws_security_group.mongo_vpc_endpoint.id
}

output "mongo_clients_sg_id" {
  description = "Atlas Project MongoDB Clients Security Group ID"
  value       = aws_security_group.mongo_clients.id
}

# ---------------------------
# Cluster Outputs
# ---------------------------
output "cluster_standard_srv" {
  description = "Atlas Cluster Standard SRV"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].standard_srv
}
output "cluster_private_srv" {
  description = "Atlas Cluster Private Connection String"
  value       = mongodbatlas_cluster.cluster.connection_strings[0].private_srv
}
output "cluster_private_endpoint_srv" {
  description = "Atlas Cluster Private Endpoint Connection String"
  value       = local.endpoint_connection_string
}
output "mongo_master_user_passwd_secrets_arn" {
  description = "AWS Secrets Manager ARN where the 'database_master_user' password is stored."
  value       = aws_secretsmanager_secret.mongo_password.id
}
output "mongo_ro_user_passwd_secrets_arn" {
  description = "AWS Secrets Manager ARN for 'ro_dbuser' password."
  value       = aws_secretsmanager_secret.mongo_ro_password.id
}
output "mongodb_uri_secrets_arn" {
  description = "AWS Secrets Manager ARN for the MongoDB URI."
  value       = aws_secretsmanager_secret.mongodb_uri.id
}

# ---------------------------
# Misc Outputs
# ---------------------------

output "aws_kms_key_arn" {
  description = "AWS KMS Key ARN"
  value       = aws_kms_key.mongoatlas_encryption_kms_key.arn
}

output "mongodb_atlas_setup_role_arn" {
  description = "MongoDB Atlas Setup Role"
  value       = aws_iam_role.mongoatlas_encryption_kms_role.arn
}
