resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "config-stripe" {
  name = "/${var.project}/config/stripe"
  type = "String"
  value = jsonencode({
    "stripeKey" : "",
    "stripeWebhockSigningKey" : ""
  })
}

resource "aws_ssm_parameter" "config-domain" {
  name = "/${var.project}/config/domain"
  type = "String"
  value = jsonencode({
    "domain" : "best-store.click"
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
    "username" : "sys-admin@mail.com",
    "password" : random_password.password.result
  })
}
resource "aws_ssm_parameter" "config-pods" {
  name = "/${var.project}/config/pods"
  type = "String"
  value = jsonencode([
    { key : "1" },
    { key : "2" }
  ])
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

