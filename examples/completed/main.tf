# ////////////////////////////////////////////
#     || DEDICATED Cluster Deployment ||
# ////////////////////////////////////////////

module "mongodb_atlas_dedicated_cluster" {
  source = "./../../"
  # ---------------------------
  # Project
  # ---------------------------
  mongodbatlas_project_name = "phx-dedicated-cluster"
  cluster_name              = "ai-manuals-mongo-db"
  component                 = "lexid"
  env_name                  = "stage"
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

  maintenance_window_hour_of_day = 1

}

