terraform {
  required_version = ">= 1.7.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.35.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}