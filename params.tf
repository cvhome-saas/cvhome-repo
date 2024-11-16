variable "aws_profile" {
  type = string
}
variable "region" {
  type = string
}
variable "app" {
  type = string
}
variable "projects" {
  type = set(string)
}