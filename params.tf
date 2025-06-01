variable "region" {
  type = string
}
variable "app" {
  type = string
}
variable "project" {
  type = string
}
variable "projects" {
  type = set(string)
}
variable "stripe-config" {
  type = object({
    stripeKey : string,
    stripeWebhockSigningKey : string
  })
}
variable "domain-config" {
  type = object({
    domain : string
  })
}
variable "kc-config" {
  type = object({
    username : string,
    password : string
  })
}