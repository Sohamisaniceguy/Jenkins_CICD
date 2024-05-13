

variable "private_subnets" {
  description = "Private subnet list"
  type = list(string)
#   default = [ "192.168.3.0/24","192.168.4.0/24" ]
}

variable "instance_type" {
  description = "Instance Type"
  type = string
  default = "t2.micro"
}



variable "image_id" {
  description = "Image ID"
  type = string
  default     = "ami-011899242bb902164"
}

variable "ec2_sg_id" {}

variable "target_group_arn" {}