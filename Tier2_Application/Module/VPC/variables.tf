variable "vpc_cidr" {
  description = "VPC_CIDR"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet list"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet list"
  type        = list(string)
}

