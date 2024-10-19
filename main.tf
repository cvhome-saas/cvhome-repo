terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "cvhome-infra-pipeline"
  alias   = "frankfort"
}

provider "aws" {
  region  = "us-east-1"
  profile = "cvhome-infra-pipeline"
  alias   = "virginia"
}

resource "aws_ecr_repository" "private_ecr_repo" {
  name = each.value
  image_scanning_configuration {
    scan_on_push = false
  }
  for_each = var.projects
  provider = aws.frankfort
}


resource "aws_ecrpublic_repository" "public_ecr_repo" {
  repository_name = each.value
  for_each        = var.projects
  provider = aws.virginia
}