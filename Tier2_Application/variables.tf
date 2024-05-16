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

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "instance_name" {
  description = "Instance Name"
  type        = string
}

variable "image_id" {
  description = "Image ID"
  type        = string
  default     = "ami-011899242bb902164"
}
