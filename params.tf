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
variable "cvhome-config" {
  type = object({
    trackUsage : string,
    usageExecededAction : string,
    nonRenewedSubscriptionAction : string
  })
}
variable "stripe-config" {
  type = object({
    stripeKey : string,
    stripeWebhockSigningKey : string
  })
}
variable "smtp-config" {
  type = object({
    host : string,
    username : string,
    password : string,
    port : string
  })
}
variable "pods-config" {
  type = list(object({
    index : number
    id : string
    name : string,
    size : string
  }))
}