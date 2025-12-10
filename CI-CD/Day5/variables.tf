variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type = string
  default = "Chowdri-rg"
}

variable "app_service_plan_name" {
  type    = string
  default = "chow3-flask-asp"
}

variable "app_service_name" {
  type    = string
  default = "chow3-flask-webapp"
}

variable "sku" {
  type    = string
  default = "B1"
}
