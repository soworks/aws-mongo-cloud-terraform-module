# ------------------------------------------------
#     || MongoDB Altas TF module variables ||
# ------------------------------------------------

# ---------------------------
# Global Variables
# ---------------------------
variable "atlas_region" {
  description = "The AWS region-name where the Atlas cluster will be deployed on."
  type        = string
  default     = "US_EAST_1"
}
variable "atlas_cloud_provider" {
  description = "Cloud service provider on which the servers are provisioned. The possible values are: AWS, GCP, AZURE, and (... TENANT - A multi-tenant deployment on one of the supported cloud service providers. Only valid when providerSettings.instanceSizeName is either M2 or M5. ...). The module only supports AWS at this moment."
  type        = string
  default     = "AWS"
  validation {
    condition     = can(regex("^(AWS|TENANT)$", var.atlas_cloud_provider))
    error_message = "Invalid atlas_cloud_provider selected, only allowed values are: 'AWS', 'TENANT. Default value 'AWS'. TENANT should only be used for SHARED cluster tiers 'atlas_cluster_type'."
  }
}

variable "atlas_encryption_cloud_provider" {
  description = "Cloud service provider on which the servers are provisioned. The possible values are: AWS, GCP, AZURE, and (... TENANT - A multi-tenant deployment on one of the supported cloud service providers. Only valid when providerSettings.instanceSizeName is either M2 or M5. ...). The module only supports AWS at this moment."
  type        = string
  default     = "AWS"
  validation {
    condition     = can(regex("^(AWS)$", var.atlas_encryption_cloud_provider))
    error_message = "Invalid atlas_cloud_provider selected, only allowed values are: 'AWS', 'TENANT. Default value 'AWS'. TENANT should only be used for SHARED cluster tiers 'atlas_cluster_type'."
  }
}
variable "component" {
  type        = string
  description = "Terraform Component Name"
}
variable "cluster_name" {
  type        = string
  description = "Mongodb cluster name. NOTE: env_name will be appended to the cluster name."
}
variable "owner" {
  type        = string
  description = "Owner Name"
  default     = "DevOps"
}
variable "env_name" {
  type        = string
  description = "Name the Environment."

  validation {
    condition     = can(regex("^(dev|stage|qa|prod)$", var.env_name))
    error_message = "Invalid atlas_cloud_provider selected, only allowed values are: 'dev', 'stage', 'qa' or 'prod"
  }
}

variable "additional_tags" {
  description = "A map of labels to be applied to created resources, in addition to the defaults."
  type        = map(string)
  default     = {}
}

variable "existing_teams" {
  type = list(object({
    id : string,
    role_names : list(string)
  }))
  description = "A list of existing teams to be associated with the project with corresponding roles."
  default     = []
}

variable "mongodb_org_id" {
  type        = string
  default     = "63ea7859fc952701885633b6"
  description = "Org ID in MongDB atlas"
  sensitive   = true
}

variable "mongodbatlas_project_name" {
  type        = string
  description = "Altas Project Name to use."
}

variable "ip_access_list" {
  type = list(object({
    type : string,
    value : string,
    comment : string
  }))
  description = "A list of IP or CIDR to be allowed to access the Atlas Cluster, should be empty by default since PrivateLink is used from AWS resources."
  default     = []
}

variable "mongodbatlas_auditing" {
  type        = bool
  default     = false
  description = "Enable auditing in MongoDB Atlas, Database auditing allows you to customize log downloads with the users, groups, and actions you want to audit."
}

# ----------------------------------
# Alerts and Notifications Variables
# ----------------------------------

variable "mongo_alarms_notifications_settings" {
  type        = map(string)
  description = "Alarm settings target configuration, by default MS_TEAMS."
  default = {
    interval_min = "15"
    delay_min    = "5"
    notification = "MICROSOFT_TEAMS"
  }
}

variable "mongo_cluster_metric_threshold" {
  type        = map(string)
  description = "Cluster metrics threshold alarm settings."
  default = {
    interval_min = "15"
    delay_min    = "5"
    notification = "MICROSOFT_TEAMS"
    operator     = "GREATER_THAN"
    threshold    = 85
    units        = "RAW"
    mode         = "AVERAGE"
  }
}

variable "mongo_query_metric_threshold" {
  type        = map(string)
  description = "Database queries threshold alarm settings."
  default = {
    interval_min = "15"
    delay_min    = "5"
    notification = "MICROSOFT_TEAMS"
    operator     = "GREATER_THAN"
    threshold    = 1000
    units        = "RAW"
    mode         = "AVERAGE"
  }
}

# ---------------------------
# Cluster Variables
# ---------------------------

variable "atlas_instance_type" {
  description = "The Atlas cluster-tier name. One of [M20|M30|]."
  type        = string
  default     = "M10"

  validation {
    condition     = can(regex("^(M20|M30)$", var.atlas_instance_type))
    error_message = "Invalid atlas_instance_type selected, only allowed values are: M10|M20|M30|. Default 'M20'"
  }
}

variable "mongo_db_major_version" {
  type        = string
  description = "The version of MongoDB to deploy to the cluster. By default 6.0"
  default     = "6.0"

  validation {
    condition     = can(regex("^(6.0|7.0)$", var.mongo_db_major_version))
    error_message = "Invalid mongo_db_major_version selected, only allowed values are: '6.0', '7.0'. Default '7.0'"
  }
}

variable "disk_size_gb" {
  type        = number
  description = "The capacity, in GB for the Atlas cluster, of each cluster instance host's root volume. AWS / GCP only."
  default     = 20
}

variable "volume_type" {
  description = "The type of the volume. The possible values are: STANDARD and PROVISIONED. PROVISIONED is ONLY required if setting IOPS higher than the default instance IOPS. This value is for AWS only"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = can(regex("^(STANDARD|PROVISIONED)$", var.volume_type))
    error_message = "Invalid volume_type selected, only allowed values are: 'STANDARD', 'PROVISIONED'. Default 'STANDARD'"
  }
}

variable "provider_disk_iops" {
  description = "The maximum input/output operations per second (IOPS) the system can perform. The possible values depend on the selected provider_instance_size_name and disk_size_gb. This setting requires that provider_instance_size_name to be M30 or greater and cannot be used with clusters with local NVMe SSDs. The default value for provider_disk_iops is the same as the cluster tier's Standard IOPS value, as viewable in the Atlas console. It is used in cases where a higher number of IOPS is needed and possible. If a value is submitted that is lower or equal to the default IOPS value for the cluster tier Atlas ignores the requested value and uses the default. More details available under the providerSettings.diskIOPS parameter"
  type        = number
  default     = null
}

variable "database_master_user" {
  description = "Mongo database user that apps will use to connect. This user will have dbAdmin role within the cluster"
  type        = string
  default     = "mongo_master_user"
}

#NOTE: If auto_scaling_compute_enabled is true, then Atlas will automatically scale up to the maximum provided and down to the minimum, if provided.
#This will cause the value of provider_instance_size_name returned to potential be different than what is specified in the Terraform config and if one then applies a plan, not noting this, Terraform will scale the cluster back down to the original instanceSizeName value.
#To prevent this a lifecycle customization should be used, i.e.:
# lifecycle { ignore_changes = [provider_instance_size_name] in the "mongodbatlas_cluster" "cluster" resources 'cluster.tf' }
variable "auto_scaling_compute_enabled" {
  description = "Specifies whether cluster tier auto-scaling is enabled. The default is false. Set to true to enable cluster tier auto-scaling. Set to false to disable cluster tier auto-scaling. "
  type        = bool
  default     = false
}

#This option is only available if autoScaling.compute.enabled is true.
variable "auto_scaling_compute_scale_down_enabled" {
  description = "Specifies whether cluster tier auto-scaling is enabled. The default is false. Set to true to enable cluster tier to scale down."
  type        = bool
  default     = false
}

#NOTE: Required if autoScaling.compute.enabled is true.
variable "provider_auto_scaling_compute_max_instance_size" {
  description = "Maximum instance size to which your cluster can automatically scale (e.g., M40)."
  type        = string
  default     = "M20"
}

variable "provider_auto_scaling_compute_min_instance_size" {
  description = "Minimum instance size to which your cluster can automatically scale (e.g., M10)."
  type        = string
  default     = "M10"
}
variable "auto_scaling_disk_gb_enabled" {
  description = "Indicating if disk auto-scaling is enabled"
  type        = bool
  default     = true
}

variable "number_of_shards" {
  type        = number
  description = "The number of shards in the cluster."
  default     = 1
}

variable "electable_nodes" {
  description = "Number of electable nodes for Atlas to deploy to the region. Electable nodes can become the primary and can facilitate local reads. The total number of electableNodes across all replication spec regions must total 3, 5, or 7. Specify 0 if you do not want any electable nodes in the region.You cannot create electable nodes in a region if priority is 0."
  type        = number
  default     = 3
}

variable "priority" {
  description = "Election priority of the region. For regions with only read-only nodes, set this value to 0. For regions where electable_nodes is at least 1, each region must have a priority of exactly one (1) less than the previous region. The first region must have a priority of 7. The lowest possible priority is 1. The priority 7 region identifies the Preferred Region of the cluster. Atlas places the primary node in the Preferred Region. Priorities 1 through 7 are exclusive - no more than one region per cluster can be assigned a given priority. Example: If you have three regions, their priorities would be 7, 6, and 5 respectively. If you added two more regions for supporting electable nodes, the priorities of those regions would be 4 and 3 respectively."
  type        = number
  default     = 7
}

variable "read_only_nodes" {
  description = "Number of read-only nodes for Atlas to deploy to the region. Read-only nodes can never become the primary, but can facilitate local-reads. Specify 0 if you do not want any read-only nodes in the region."
  type        = number
  default     = 0
}

variable "cloud_backup" {
  description = "Flag indicating if the cluster uses Cloud Backup for backups."
  type        = bool
  default     = true
}

variable "pit_enabled" {
  description = "Indicating if the cluster uses Continuous Cloud Backup, if set to true - cloud_backup must also be set to true."
  type        = bool
  default     = true
}

variable "database_specifics_statistics" {
  description = "is collect database specifics statistics enabled?."
  type        = bool
  default     = true
}

variable "data_explorer" {
  description = "is data explorer enabled?."
  type        = bool
  default     = true
}

variable "extended_storage_sizes" {
  description = "is data explorer enabled?."
  type        = bool
  default     = true
}

variable "performance_advisor" {
  description = "is performance advisor enabled?."
  type        = bool
  default     = true
}

variable "realtime_performance_panel" {
  description = "is realtime performance panel enabled?."
  type        = bool
  default     = true
}

variable "schema_advisor" {
  description = "is schema advisor enabled?."
  type        = bool
  default     = true
}

variable "termination_protection" {
  description = "Indicating if the cluster is protected from being terminated. By default, will be set to true if env_name is qa or prod."
  type        = bool
  default     = null
}

variable "deletion_window_in_days" {
  type        = number
  default     = 30
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled"
}

variable "description" {
  type        = string
  default     = "CMK for mongodb Atlas encryption at Rest"
  description = "The description of the key as viewed in AWS console"
}


variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`."

  validation {
    condition     = can(regex("^(ENCRYPT_DECRYPT|SIGN_VERIFY|)$", var.key_usage))
    error_message = "Invalid key_usage selected, only allowed values are: 'ENCRYPT_DECRYPT', 'SIGN_VERIFY'. Default 'ENCRYPT_DECRYPT'"
  }
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`."
  validation {
    condition     = can(regex("^(SYMMETRIC_DEFAULT|RSA_2048|RSA_3072|ECC_NIST_P256|ECC_NIST_P384|ECC_NIST_P521|ECC_SECG_P256K1)$", var.customer_master_key_spec))
    error_message = "Invalid key_usage selected, check the module README to see allowed values. Default 'SYMMETRIC_DEFAULT'"
  }
}

variable "maintenance_window_day_of_week" {
  description = "Day of the week when you would like the maintenance window to start as a 1-based integer: S=1, M=2, T=3, W=4, T=5, F=6, S=7."
  type        = number
  default     = 7
  validation {
    condition = (
      var.maintenance_window_day_of_week >= 1 &&
      var.maintenance_window_day_of_week <= 7
    )
    error_message = "Invalid value. Expected values are S=1, M=2, T=3, W=4, T=5, F=6, S=7"
  }
}

variable "maintenance_window_hour_of_day" {
  description = "Hour of the day when you would like the maintenance window to start. This parameter uses the 24-hour clock, where midnight is 0, noon is 12 (Time zone is UTC)."
  type        = number
  default     = 4
  validation {
    condition = (
      var.maintenance_window_hour_of_day >= 0 &&
      var.maintenance_window_hour_of_day <= 24
    )
    error_message = "Invalid value. Expected valunes are '0' to '24'. This parameter uses the 24-hour clock, where midnight is 0, noon is 12 (Time zone is UTC)."
  }
}

variable "backup_config" {
  description = "Backup configuration for the cluster."
  type = object({
    reference_hour_of_day    = number
    reference_minute_of_hour = number
    restore_window_days      = number
    policy_item_hourly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    policy_item_daily = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    policy_item_weekly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
    policy_item_monthly = optional(object({
      frequency_interval = number
      retention_unit     = string
      retention_value    = number
    }))
  })
  default = {
    "reference_hour_of_day"    = 4,
    "reference_minute_of_hour" = 45,
    "restore_window_days"      = 2,
    "policy_item_hourly" = {
      "frequency_interval" = 6,
      "retention_unit"     = "days",
      "retention_value"    = 2
    },
    "policy_item_daily" = {
      "frequency_interval" = 1,
      "retention_unit"     = "days",
      "retention_value"    = 7
    },
    "policy_item_weekly" = {
      "frequency_interval" = 6,
      "retention_unit"     = "weeks",
      "retention_value"    = 4
    },
    "policy_item_monthly" = {
      "frequency_interval" = 40,
      "retention_unit"     = "months",
      "retention_value"    = 12
    }
  }
}

variable "mongodb_allowed_security_group_ids" {
  description = "A list of security group IDs to allow access to the Atlas cluster. This is required for any client to connect to the mongodb cluster."
  type        = list(string)
  default     = []
}

variable "mongodb_uri_suffix" {
  description = "The suffix to be appended to the mongodb URI. This is useful for adding additional parameters to the URI."
  type        = string
  default     = "/?retryWrites=true&w=majority"
}