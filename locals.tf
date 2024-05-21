#The module from mongodb itself is limited to AWS only for now.

locals {
  # ----------------
  #   || Global ||
  # ----------------
  custom_tags    = var.additional_tags == null ? {} : var.additional_tags
  existing_teams = var.existing_teams == null ? [] : var.existing_teams
  ip_access_list = var.ip_access_list == null ? [] : var.ip_access_list

  default_tags = {
    project_name         = "phoenix"
    component            = var.component
    environment          = var.env_name
    deploymentIdentifier = local.cluster_name
    owner                = var.owner
    managedby            = "terraform"
  }
  tags = merge(local.custom_tags, local.default_tags)

  # --------------------
  #   || Project  ||
  # --------------------

  project_limits = [
    {
      name : "atlas.project.deployment.clusters"
      value : "3"
    },
    {
      name : "atlas.project.deployment.nodesPerPrivateLinkRegion"
      value : "3"
    },
  ]
  resolved_existing_teams = {
    for existing_team in local.existing_teams : existing_team.id => existing_team
  }
  resolved_project_limits = {
    for project_limits in local.project_limits : project_limits.name => project_limits
  }
  resolved_cidr_block_entries = {
    for entry in local.ip_access_list :
    entry.value => entry
    if entry.type == "cidr-block"
  }

  # --------------------
  #   || Cluster  ||
  # --------------------

  number_of_shards       = var.number_of_shards == null ? 1 : var.number_of_shards
  cluster_name           = lower(replace("${var.cluster_name}-${var.env_name}", "_", "-")) # cluster name should be lower case and hyphenated
  termination_protection = var.termination_protection == null ? can(regex(var.env_name, "^(qa|prod)$")) : var.termination_protection

  private_endpoints = flatten([for cs in mongodbatlas_cluster.cluster.connection_strings : cs.private_endpoint])

  connection_strings = [
    for pe in local.private_endpoints : pe.srv_connection_string
    if contains([for e in pe.endpoints : e.endpoint_id], aws_vpc_endpoint.mongo_vpc_endpoint.id)
  ]

  endpoint_connection_string = length(local.connection_strings) > 0 ? local.connection_strings[0] : ""
}


