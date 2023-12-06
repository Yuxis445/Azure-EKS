variable "region" {
  type = string
  default = "West US 3"
}

variable "environment" {
  type = string
  default = "test"
}

variable "network_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "enable_argo" {
  type = string
  default = 1
}

variable "mydomain" {
  type = string
  default = "anontests.xyz"
}