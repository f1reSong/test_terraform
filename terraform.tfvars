aws_region     = "us-east-1"
vpc_cidr_block = "10.100.0.0/16"
azs            = ["us-east-1a", "us-east-1b"]
public_subnets = ["10.100.0.0/24", "10.100.1.0/24"]
private_subnets = {
  "10.100.10.0/24" = {
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
}
prefix = "my-app"
tags = {
  "env"        = "production",
  "maintainer" = "Sh_Kurbanbaev"
}
vpc_tags = {
  "my_vpc" = "just example vpc tag"
}

vpc_name = "my-vpc"
domain   = "mydomain.example"