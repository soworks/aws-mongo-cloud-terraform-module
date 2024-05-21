variable "component" {
  type        = string
  description = "Terraform Component Name"
  default     = "projectX"
}
variable "owner" {
  type        = string
  description = "Owner Name"
  default     = "DevOps"
}
variable "env_name" {
  type        = string
  description = "Name the Environment"
  default     = "stage"

  validation {
    condition     = can(regex("^(dev|stage|qa|prod)$", var.env_name))
    error_message = "Invalid atlas_cloud_provider selected, only allowed values are: 'dev', 'stage', 'qa' or 'prod"
  }
}
variable "mongodb_org_id" {
  type        = string
  description = "Org ID in MongDB atlas"
  sensitive   = true
}
