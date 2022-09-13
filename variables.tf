variable "aws_region" {
  type        = string
  description = "Specify AWS region"
}

variable "vpc_cidr_block" {
  type        = string
  description = "Specify VPC Cidr block"
}

variable "prefix" {
  type        = string
  description = "Prefix in whole infrastructure(Can be blank)"
  default     = "myapp"
}

variable "tags" {
  type        = map(string)
  description = "Specify tags for full infrastructure"
  default     = {}
}

variable "vpc_tags" {
  type        = map(string)
  description = "Specify tags for vpc"
  default     = {}
}

variable "igw_tags" {
  type        = map(string)
  description = "Specify tags for шпц"
  default     = {}
}

variable "public_route_table_tags" {
  type        = map(string)
  description = "Specify tags for public route table"
  default     = {}
}

variable "vpc_name" {
  type        = string
  description = "Specify vpc name"
  default     = "vpc"
}

variable "public_subnets" {
  type        = list(string)
  description = "Specify public subnets in list format( e.g. ['10.0.0.0/24', '10.0.1.0/24'])"
  validation {
    condition     = length(var.public_subnets) == 2
    error_message = "For more durability and fault tolerance required to set 2 subnets"
  }
}

variable "private_subnets" {
  type        = map(any)
  description = <<-EOD
  Specify private subnets and parameters in map of maps format, where key is subnet
  ( e.g.     "10.100.10.0/24" = {
        "az" = "us-east-1a",
        "tags" = {
            "example_subnet_tag" = "qwerty"
        }
    },
    "10.100.11.0/24" = {
        "az" = "us-east-1b",
        "tags" = {
            "example_subnet_tag" = "qwerty"
        }
    }
})
  EOD
  validation {
    condition     = length(var.private_subnets) == 2
    error_message = "For more durability and fault tolerance required to set 2 subnets"
  }
}

variable "azs" {
  type        = list(string)
  description = <<-EOD
  Setup availability zones. It's not required parameter, but it's importand if you build high 
  available apllications
  EOD
  default     = []
}

variable "public_subnet_tags" {
  type        = map(string)
  description = "subnet tags"
  default     = {}
}

variable "domain" {
  type = string
}