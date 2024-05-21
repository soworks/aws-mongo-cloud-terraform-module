# ------------------------------------------------
#     || MongoDB Altas TF module outputs ||
# ------------------------------------------------

# ---------------------------
# Project Outputs 
# ---------------------------
output "project_id" {
  description = "Atlas Project ID"
  value       = module.mongodb_atlas_dedicated_cluster.project_id
}

# ---------------------------
# Network Outputs 
# ---------------------------
output "private_link_id" {
  description = "Atlas Project Prviate Link ID"
  value       = module.mongodb_atlas_dedicated_cluster.private_link_id
}
output "endpoint_service_name" {
  description = "Atlas Project endpoint Service Name"
  value       = module.mongodb_atlas_dedicated_cluster.endpoint_service_name
}
output "interface_endpoint_id" {
  description = "Atlas Project interface Endpoint ID"
  value       = module.mongodb_atlas_dedicated_cluster.interface_endpoint_id
}
