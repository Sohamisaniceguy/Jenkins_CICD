variable "vpc_cidr" {
  description = "VPC_CIDR"
  type = string
}

variable "public_subnets" {
  description = "Public subnet list"
  type = list(string)
}

variable "private_subnets_web" {
  description = "Private subnet list"
  type = list(string)
}

variable "private_subnets_db" {
  description = "Private subnet list"
  type = list(string)
}

variable "all_private_subnets" {
  type = list(string)
  default = concat(var.private_subnets_web, var.private_subnets_db)
}

variable "instance_type" {
  description = "Instance Type"
  type = string
}
