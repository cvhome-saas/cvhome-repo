terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.75.0"
    }
  }
}

provider "aws" {
  region = var.region
  alias  = "frankfort"
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

resource "aws_ecr_repository" "private_ecr_repo" {
  name = each.value
  image_scanning_configuration {
    scan_on_push = false
  }
  for_each     = var.projects
  provider     = aws.frankfort
  force_delete = true
}

resource "aws_ecrpublic_repository" "public_ecr_repo" {
  repository_name = each.value
  for_each        = var.projects
  provider        = aws.virginia
  force_destroy   = true
}

resource "aws_iam_user" "ecr-releaser" {
  name          = "ecr-releaser"
  provider      = aws.virginia
  force_destroy = true
}

data "aws_iam_policy_document" "ecr-private-releaser" {
  statement {
    sid    = "s1"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
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
      "ecr-public:GetAuthorizationToken",
      "ecr-public:DescribeRegistries",
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "s2"
    effect = "Allow"
    actions = [
      "ecr-public:GetAuthorizationToken",
      "ecr-public:BatchGetImage",
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:CompleteLayerUpload",
      "ecr-public:GetDownloadUrlForLayer",
      "ecr-public:InitiateLayerUpload",
      "ecr-public:PutImage",
      "ecr-public:UploadLayerPart"
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


data "aws_iam_policy_document" "ecs-deploy" {
  statement {
    sid    = "s1"
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs-deploy" {
  name     = "ecs-deploy-policy"
  policy   = data.aws_iam_policy_document.ecs-deploy.json
  provider = aws.frankfort
}

resource "aws_iam_policy_attachment" "ecs-deploy-releaser" {
  name       = "ecs-deploy-attachment"
  policy_arn = aws_iam_policy.ecs-deploy.arn
  users = [aws_iam_user.ecr-releaser.name]
  provider   = aws.frankfort
}

resource "aws_ssm_parameter" "config-stripe" {
  name = "/${var.project}/config/stripe"
  type = "String"
  value = jsonencode({
    "key" : "",
    "signingKey" : ""
  })
}
resource "aws_ssm_parameter" "config-domain" {
  name = "/${var.project}/config/domain"
  type = "String"
  value = jsonencode({
    "domain" : "",
    "domainCertificateArn" : ""
  })
}
resource "aws_ssm_parameter" "config-smtp" {
  name = "/${var.project}/config/smtp"
  type = "String"
  value = jsonencode({
    "host" : "",
    "username" : "",
    "password" : "",
    "port" : ""
  })
}
resource "aws_ssm_parameter" "config-kc" {
  name = "/${var.project}/config/kc"
  type = "String"
  value = jsonencode({
    "username" : "",
    "password" : ""
  })
}
resource "aws_ssm_parameter" "config-cvhome" {
  name = "/${var.project}/config/cvhome"
  type = "String"
  value = jsonencode({
    "trackUsage" : "false",
    "usageExecededAction" : "continue",
    "nonRenewedSubscriptionAction" : "continue"
  })
}

