data "mongodbatlas_teams" "devops_team" {
  org_id = var.mongodb_org_id
  name   = "DevOps"
}

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

data "aws_security_group" "vpc-endpoints-sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-phx-vpc-endpoints-sg"]
  }
}

