# Terraform Module: MongoDB Atlas AWS

## Overview

This Terraform module enables the automated provisioning of a MongoDB Atlas project, cluster, alerts, encryption at rest using AWS KMS, backups, maintenance window, and network configuration using AWS Endpoints and MongoDB Atlas private link.

## Usage

```hcl
# ////////////////////////////////////////////
#     || DEDICATED Cluster Deployment ||
# ////////////////////////////////////////////

module "mongodb_atlas_dedicated_cluster" {
  source = ""git::ssh://git@bitbucket.org/lexipol/ terraform-mongodbatlas-cluster.git?ref=v1.0.1"
  # ---------------------------
  # Project
  # ---------------------------
  mongodbatlas_project_name = "phx-dedicated-cluster"
  mongodbatlas_auditing     = true
  //Add addtional CIDRs example
  ip_access_list = [
    {
      type : "cidr-block"
      value : "192.168.0.0/16"
      comment : "Corp. VPN CIDR block"
    }
  ]
  //Add existing teams in Mongoatlas (the team ID must be declared as a data resource in data.tf)
  existing_teams = [
    {
      name : "DevOps"
      id : data.mongodbatlas_teams.devops_team.team_id
      role_names : ["GROUP_OWNER", "GROUP_CLUSTER_MANAGER"]
    },
  ]
  //Add addtional tags example
  additional_tags = {
    Deployment_type = "This is a dedicated cluster"
  }

  # ---------------------------
  # Cluster + DEDICATED
  # ---------------------------
  atlas_instance_type    = "M10"
  mongo_db_major_version = "6.0"
  disk_size_gb           = 20
  volume_type            = "STANDARD"
  cloud_backup           = true

  # --------------------------------------
  # Cloud Backup & Maintenance Window
  # --------------------------------------
  maintenance_window_day_of_week = 6
  maintenance_window_hour_of_day = 1

}
```

## Required Access
- atlas_api_key (Required): Your MongoDB Atlas API key.
- aws_access_key (Required): Your AWS access key.
- aws_secret_key (Required): Your AWS secret key.


## Examples
- You can find usage examples in the examples/completed directory.

<!-- BEGIN_TF_DOCS -->
#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 5.35 |
| <a name="provider_mongodbatlas"></a> [mongodbatlas](#provider_mongodbatlas) | ~> 1.15.0 |
| <a name="provider_random"></a> [random](#provider_random) | ~> 3.6.0 |
| <a name="provider_time"></a> [time](#provider_time) | ~> 0.10.0 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_msteams_notification"></a> [msteams_notification](#module_msteams_notification) | git::ssh://git@bitbucket.org/lexipol/terraform-aws-teams-notifications.git | v1.0.4 |

#### Inputs

| Name | Description | Type |
|------|-------------|------|
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | Mongodb cluster name. NOTE: env_name will be appended to the cluster name. | `string` |
| <a name="input_component"></a> [component](#input_component) | Terraform Component Name | `string` |
| <a name="input_env_name"></a> [env_name](#input_env_name) | Name the Environment. | `string` |
| <a name="input_mongodbatlas_project_name"></a> [mongodbatlas_project_name](#input_mongodbatlas_project_name) | Altas Project Name to use. | `string` |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags) | A map of labels to be applied to created resources, in addition to the defaults. | `map(string)` |
| <a name="input_atlas_cloud_provider"></a> [atlas_cloud_provider](#input_atlas_cloud_provider) | Cloud service provider on which the servers are provisioned. The possible values are: AWS, GCP, AZURE, and (... TENANT - A multi-tenant deployment on one of the supported cloud service providers. Only valid when providerSettings.instanceSizeName is either M2 or M5. ...). The module only supports AWS at this moment. | `string` |
| <a name="input_atlas_encryption_cloud_provider"></a> [atlas_encryption_cloud_provider](#input_atlas_encryption_cloud_provider) | Cloud service provider on which the servers are provisioned. The possible values are: AWS, GCP, AZURE, and (... TENANT - A multi-tenant deployment on one of the supported cloud service providers. Only valid when providerSettings.instanceSizeName is either M2 or M5. ...). The module only supports AWS at this moment. | `string` |
| <a name="input_atlas_instance_type"></a> [atlas_instance_type](#input_atlas_instance_type) | The Atlas cluster-tier name. One of [M20\|M30\|]. | `string` |
| <a name="input_atlas_region"></a> [atlas_region](#input_atlas_region) | The AWS region-name where the Atlas cluster will be deployed on. | `string` |
| <a name="input_auto_scaling_compute_enabled"></a> [auto_scaling_compute_enabled](#input_auto_scaling_compute_enabled) | Specifies whether cluster tier auto-scaling is enabled. The default is false. Set to true to enable cluster tier auto-scaling. Set to false to disable cluster tier auto-scaling. | `bool` |
| <a name="input_auto_scaling_compute_scale_down_enabled"></a> [auto_scaling_compute_scale_down_enabled](#input_auto_scaling_compute_scale_down_enabled) | Specifies whether cluster tier auto-scaling is enabled. The default is false. Set to true to enable cluster tier to scale down. | `bool` |
| <a name="input_auto_scaling_disk_gb_enabled"></a> [auto_scaling_disk_gb_enabled](#input_auto_scaling_disk_gb_enabled) | Indicating if disk auto-scaling is enabled | `bool` |
| <a name="input_backup_config"></a> [backup_config](#input_backup_config) | Backup configuration for the cluster. | <pre>object({<br>    reference_hour_of_day    = number<br>    reference_minute_of_hour = number<br>    restore_window_days      = number<br>    policy_item_hourly = optional(object({<br>      frequency_interval = number<br>      retention_unit     = string<br>      retention_value    = number<br>    }))<br>    policy_item_daily = optional(object({<br>      frequency_interval = number<br>      retention_unit     = string<br>      retention_value    = number<br>    }))<br>    policy_item_weekly = optional(object({<br>      frequency_interval = number<br>      retention_unit     = string<br>      retention_value    = number<br>    }))<br>    policy_item_monthly = optional(object({<br>      frequency_interval = number<br>      retention_unit     = string<br>      retention_value    = number<br>    }))<br>  })</pre> |
| <a name="input_cloud_backup"></a> [cloud_backup](#input_cloud_backup) | Flag indicating if the cluster uses Cloud Backup for backups. | `bool` |
| <a name="input_customer_master_key_spec"></a> [customer_master_key_spec](#input_customer_master_key_spec) | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`, `ECC_NIST_P521`, or `ECC_SECG_P256K1`. | `string` |
| <a name="input_data_explorer"></a> [data_explorer](#input_data_explorer) | is data explorer enabled?. | `bool` |
| <a name="input_database_master_user"></a> [database_master_user](#input_database_master_user) | Mongo database user that apps will use to connect. This user will have dbAdmin role within the cluster | `string` |
| <a name="input_database_specifics_statistics"></a> [database_specifics_statistics](#input_database_specifics_statistics) | is collect database specifics statistics enabled?. | `bool` |
| <a name="input_deletion_window_in_days"></a> [deletion_window_in_days](#input_deletion_window_in_days) | Duration in days after which the key is deleted after destruction of the resource | `number` |
| <a name="input_description"></a> [description](#input_description) | The description of the key as viewed in AWS console | `string` |
| <a name="input_disk_size_gb"></a> [disk_size_gb](#input_disk_size_gb) | The capacity, in GB for the Atlas cluster, of each cluster instance host's root volume. AWS / GCP only. | `number` |
| <a name="input_electable_nodes"></a> [electable_nodes](#input_electable_nodes) | Number of electable nodes for Atlas to deploy to the region. Electable nodes can become the primary and can facilitate local reads. The total number of electableNodes across all replication spec regions must total 3, 5, or 7. Specify 0 if you do not want any electable nodes in the region.You cannot create electable nodes in a region if priority is 0. | `number` |
| <a name="input_enable_key_rotation"></a> [enable_key_rotation](#input_enable_key_rotation) | Specifies whether key rotation is enabled | `bool` |
| <a name="input_existing_teams"></a> [existing_teams](#input_existing_teams) | A list of existing teams to be associated with the project with corresponding roles. | <pre>list(object({<br>    id : string,<br>    role_names : list(string)<br>  }))</pre> |
| <a name="input_extended_storage_sizes"></a> [extended_storage_sizes](#input_extended_storage_sizes) | is data explorer enabled?. | `bool` |
| <a name="input_ip_access_list"></a> [ip_access_list](#input_ip_access_list) | A list of IP or CIDR to be allowed to access the Atlas Cluster, should be empty by default since PrivateLink is used from AWS resources. | <pre>list(object({<br>    type : string,<br>    value : string,<br>    comment : string<br>  }))</pre> |
| <a name="input_key_usage"></a> [key_usage](#input_key_usage) | Specifies the intended use of the key. Valid values: `ENCRYPT_DECRYPT` or `SIGN_VERIFY`. | `string` |
| <a name="input_maintenance_window_day_of_week"></a> [maintenance_window_day_of_week](#input_maintenance_window_day_of_week) | Day of the week when you would like the maintenance window to start as a 1-based integer: S=1, M=2, T=3, W=4, T=5, F=6, S=7. | `number` |
| <a name="input_maintenance_window_hour_of_day"></a> [maintenance_window_hour_of_day](#input_maintenance_window_hour_of_day) | Hour of the day when you would like the maintenance window to start. This parameter uses the 24-hour clock, where midnight is 0, noon is 12 (Time zone is UTC). | `number` |
| <a name="input_mongo_alarms_notifications_settings"></a> [mongo_alarms_notifications_settings](#input_mongo_alarms_notifications_settings) | Alarm settings target configuration, by default MS_TEAMS. | `map(string)` |
| <a name="input_mongo_cluster_metric_threshold"></a> [mongo_cluster_metric_threshold](#input_mongo_cluster_metric_threshold) | Cluster metrics threshold alarm settings. | `map(string)` |
| <a name="input_mongo_db_major_version"></a> [mongo_db_major_version](#input_mongo_db_major_version) | The version of MongoDB to deploy to the cluster. By default 6.0 | `string` |
| <a name="input_mongo_query_metric_threshold"></a> [mongo_query_metric_threshold](#input_mongo_query_metric_threshold) | Database queries threshold alarm settings. | `map(string)` |
| <a name="input_mongodb_allowed_security_group_ids"></a> [mongodb_allowed_security_group_ids](#input_mongodb_allowed_security_group_ids) | A list of security group IDs to allow access to the Atlas cluster. This is required for any client to connect to the mongodb cluster. | `list(string)` |
| <a name="input_mongodb_org_id"></a> [mongodb_org_id](#input_mongodb_org_id) | Org ID in MongDB atlas | `string` |
| <a name="input_mongodbatlas_auditing"></a> [mongodbatlas_auditing](#input_mongodbatlas_auditing) | Enable auditing in MongoDB Atlas, Database auditing allows you to customize log downloads with the users, groups, and actions you want to audit. | `bool` |
| <a name="input_number_of_shards"></a> [number_of_shards](#input_number_of_shards) | The number of shards in the cluster. | `number` |
| <a name="input_owner"></a> [owner](#input_owner) | Owner Name | `string` |
| <a name="input_performance_advisor"></a> [performance_advisor](#input_performance_advisor) | is performance advisor enabled?. | `bool` |
| <a name="input_pit_enabled"></a> [pit_enabled](#input_pit_enabled) | Indicating if the cluster uses Continuous Cloud Backup, if set to true - cloud_backup must also be set to true. | `bool` |
| <a name="input_priority"></a> [priority](#input_priority) | Election priority of the region. For regions with only read-only nodes, set this value to 0. For regions where electable_nodes is at least 1, each region must have a priority of exactly one (1) less than the previous region. The first region must have a priority of 7. The lowest possible priority is 1. The priority 7 region identifies the Preferred Region of the cluster. Atlas places the primary node in the Preferred Region. Priorities 1 through 7 are exclusive - no more than one region per cluster can be assigned a given priority. Example: If you have three regions, their priorities would be 7, 6, and 5 respectively. If you added two more regions for supporting electable nodes, the priorities of those regions would be 4 and 3 respectively. | `number` |
| <a name="input_provider_auto_scaling_compute_max_instance_size"></a> [provider_auto_scaling_compute_max_instance_size](#input_provider_auto_scaling_compute_max_instance_size) | Maximum instance size to which your cluster can automatically scale (e.g., M40). | `string` |
| <a name="input_provider_auto_scaling_compute_min_instance_size"></a> [provider_auto_scaling_compute_min_instance_size](#input_provider_auto_scaling_compute_min_instance_size) | Minimum instance size to which your cluster can automatically scale (e.g., M10). | `string` |
| <a name="input_provider_disk_iops"></a> [provider_disk_iops](#input_provider_disk_iops) | The maximum input/output operations per second (IOPS) the system can perform. The possible values depend on the selected provider_instance_size_name and disk_size_gb. This setting requires that provider_instance_size_name to be M30 or greater and cannot be used with clusters with local NVMe SSDs. The default value for provider_disk_iops is the same as the cluster tier's Standard IOPS value, as viewable in the Atlas console. It is used in cases where a higher number of IOPS is needed and possible. If a value is submitted that is lower or equal to the default IOPS value for the cluster tier Atlas ignores the requested value and uses the default. More details available under the providerSettings.diskIOPS parameter | `number` |
| <a name="input_read_only_nodes"></a> [read_only_nodes](#input_read_only_nodes) | Number of read-only nodes for Atlas to deploy to the region. Read-only nodes can never become the primary, but can facilitate local-reads. Specify 0 if you do not want any read-only nodes in the region. | `number` |
| <a name="input_realtime_performance_panel"></a> [realtime_performance_panel](#input_realtime_performance_panel) | is realtime performance panel enabled?. | `bool` |
| <a name="input_schema_advisor"></a> [schema_advisor](#input_schema_advisor) | is schema advisor enabled?. | `bool` |
| <a name="input_termination_protection"></a> [termination_protection](#input_termination_protection) | Indicating if the cluster is protected from being terminated. By default, will be set to true if env_name is qa or prod. | `bool` |
| <a name="input_volume_type"></a> [volume_type](#input_volume_type) | The type of the volume. The possible values are: STANDARD and PROVISIONED. PROVISIONED is ONLY required if setting IOPS higher than the default instance IOPS. This value is for AWS only | `string` |
<!-- END_TF_DOCS -->