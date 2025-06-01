resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "config-stripe" {
  name = "/${var.project}/config/stripe"
  type = "String"
  value = jsonencode(var.stripe-config)
}

resource "aws_ssm_parameter" "config-domain" {
  name = "/${var.project}/config/domain"
  type = "String"
  value = jsonencode(var.domain-config)
}
resource "aws_ssm_parameter" "config-kc" {
  name = "/${var.project}/config/kc"
  type = "String"
  value = jsonencode(merge(var.kc-config), {
    password : random_password.password.result
  })
}

