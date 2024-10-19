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
  provider        = aws.virginia
}

resource "aws_iam_user" "ecr-releaser" {
  name     = "ecr-releaser"
  provider = aws.virginia
}

data "aws_iam_policy_document" "ecr-private-releaser" {
  statement {
    sid    = "s1"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "s2"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [for i in aws_ecr_repository.private_ecr_repo : i.arn]
  }
}

resource "aws_iam_policy" "ecr-private-releaser" {
  name     = "ecr-private-releaser-policy"
  policy   = data.aws_iam_policy_document.ecr-private-releaser.json
  provider = aws.virginia
}

resource "aws_iam_policy_attachment" "ecr-private-releaser" {
  name       = "ecr-private-releaser-attachment"
  policy_arn = aws_iam_policy.ecr-private-releaser.arn
  users = [aws_iam_user.ecr-releaser.name]
  provider   = aws.virginia
}

data "aws_iam_policy_document" "ecr-public-releaser" {
  statement {
    sid    = "s1"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "s2"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [for i in aws_ecrpublic_repository.public_ecr_repo : i.arn]
  }
}

resource "aws_iam_policy" "ecr-public-releaser" {
  name     = "ecr-public-releaser-policy"
  policy   = data.aws_iam_policy_document.ecr-public-releaser.json
  provider = aws.virginia
}

resource "aws_iam_policy_attachment" "ecr-public-releaser" {
  name       = "ecr-public-releaser-attachment"
  policy_arn = aws_iam_policy.ecr-public-releaser.arn
  users = [aws_iam_user.ecr-releaser.name]
  provider   = aws.virginia
}