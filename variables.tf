variable "aws_region" {
  type = string
  description = "Specify AWS region"
}

variable "vpc_cidr_block" {
  type = string
  description = "Specify VPC Cidr block"
}

variable "prefix" {
  type = string
  description = "Prefix in whole infrastructure(Can be blank)"
  default = ""
}

variable "tags" {
  type = map
  description = "Specify tags for full infrastructure"
  default = {}
}

variable "vpc_tags" {
  type = map
  description = "Specify tags for vpc"
  default = {}
}

variable "vpc_name" {
  type = string
  description = "Specify vpc name"
  default = "vpc"
}