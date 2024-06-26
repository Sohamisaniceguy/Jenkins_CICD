variable "vpc_cidr" {
  description = "VPC_CIDR"
  type = string
}

variable "public_subnets" {
  description = "Public subnet list"
  type = list(string)
}

variable "instance_type" {
  description = "Instance Type"
  type = string
}

