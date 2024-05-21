# ------------------------------------------------
#   || AWS Resources for Private Network Acces ||
# ------------------------------------------------

# ---------------------------
# Atlas PrivateLink Endpoint
# ---------------------------

resource "mongodbatlas_privatelink_endpoint" "endpoint" {
  project_id    = mongodbatlas_project.atlas_project.id
  provider_name = "AWS"
  region        = data.aws_region.current.name
  depends_on    = [mongodbatlas_project.atlas_project, mongodbatlas_encryption_at_rest.encryption]
  lifecycle {
    create_before_destroy = true
  }
}

resource "mongodbatlas_privatelink_endpoint_service" "service" {
  project_id          = mongodbatlas_project.atlas_project.id
  private_link_id     = mongodbatlas_privatelink_endpoint.endpoint.private_link_id
  endpoint_service_id = aws_vpc_endpoint.mongo_vpc_endpoint.id
  provider_name       = "AWS"
  depends_on = [aws_vpc_endpoint.mongo_vpc_endpoint,
    mongodbatlas_encryption_at_rest.encryption,
  mongodbatlas_privatelink_endpoint.endpoint]
  lifecycle {
    create_before_destroy = true
  }
}

# Dedicated security group for MongoDB Atlas PrivateLink
resource "aws_security_group" "mongo_vpc_endpoint" {
  description = "Security group for MongoDB Atlas PrivateLink Endpoint access."
  name_prefix = "${local.cluster_name}-phx-vpc-endpoints-sg"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name = "${local.cluster_name}-phx-vpc-endpoints-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Dedicated security group for access to MongoDB
resource "aws_security_group" "mongo_clients" {
  description = "Security group for ${local.cluster_name} MongoDB client access via privatelink."
  name_prefix = "${local.cluster_name}-phx-mongo-clients-sg"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name = "${local.cluster_name}-phx-mongo-clients-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Allow Mongo clients access to the MongoDB Atlas PrivateLink Endpoint
# NOTE: In testing, connectivity does not work unless we allow all traffic. Restricting to ports 27017 through 27015 does not work.
resource "aws_vpc_security_group_ingress_rule" "mongo_vpc_endpoint_allow_mongo_clients" {
  #checkov:skip=CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389 - this is temp for now until we have a better solution"
  #checkov:skip=CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22 - this is temp for now until we have a better solution"
  #checkov:skip=CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80 - this is temp for now until we have a better solution"
  description                  = "Allow access to the MongoDB Atlas PrivateLink Endpoint"
  security_group_id            = aws_security_group.mongo_vpc_endpoint.id
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.mongo_clients.id
}

resource "aws_vpc_security_group_ingress_rule" "mongo_vpc_endpoint_allow_other_mongo_clients" {
  #checkov:skip=CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389 - this is temp for now until we have a better solution"
  #checkov:skip=CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22 - this is temp for now until we have a better solution"
  #checkov:skip=CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80 - this is temp for now until we have a better solution"
  for_each                     = toset(var.mongodb_allowed_security_group_ids)
  description                  = "Allow access to the MongoDB Atlas PrivateLink Endpoint"
  security_group_id            = aws_security_group.mongo_vpc_endpoint.id
  ip_protocol                  = "-1"
  referenced_security_group_id = each.value
}

resource "aws_vpc_security_group_egress_rule" "mongo_vpc_endponit_allow_all" {
  description       = "Allow all traffic from MongoDB Atlas PrivateLink Endpoint to VPC"
  security_group_id = aws_security_group.mongo_vpc_endpoint.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}


# ---------------------------
# AWS VPC Endpoint
# ---------------------------

resource "aws_vpc_endpoint" "mongo_vpc_endpoint" {
  vpc_id             = data.aws_vpc.vpc.id
  service_name       = mongodbatlas_privatelink_endpoint.endpoint.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [aws_security_group.mongo_vpc_endpoint.id]
  tags = {
    Name = "${local.cluster_name}-mongoatlas-privatelink-endpoint"
  }
  depends_on = [mongodbatlas_privatelink_endpoint.endpoint]

  lifecycle {
    create_before_destroy = true
  }
}
