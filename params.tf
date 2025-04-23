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
variable "pods" {
  type = list(object({
    index : number
    id : string
    name : string,
    size : string
  }))
}