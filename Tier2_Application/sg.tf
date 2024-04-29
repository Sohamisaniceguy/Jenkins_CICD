# #ALB - SG:
module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "SecurityG-ALB"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks =[
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name= "ALB-SG"
  }
}


# #EC2:
module "ec2_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "SecurityG-EC2"
  description = "Security group for EC2"
  vpc_id      = module.vpc.vpc_id
  security_group_id = module.alb_sg.security_group_id

  ingress_with_source_security_group_id = [
    {
      description              = "HTTP from service one"
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      description              = "HTTPS from service one"
      rule                     = "https-443-tcp"
      source_security_group_id = data.alb_sg.security_group_id
    },
    {
      description           = "SSH from all"
      rule                  = "ssh-22-tcp"
      cidr_blocks           = ["0.0.0.0/0"]
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = {
    Name = "EC2-SG"
  }
}


# module "db_sg" {
#   source = "terraform-aws-modules/security-group/aws"

#   name        = "SecurityG-DB"
#   description = "Security group for DB"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_source_security_group_id = [
#     {
#       from_port   = 3360
#       to_port     = 3360
#       protocol    = "tcp"
#       description = "HTTP"
#     #   cidr_blocks = "0.0.0.0/0"
#       security_group=module.ec2_sg.security_group_id
#     },
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       description = "HTTP"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   egress_with_cidr_blocks =[
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       description = "All"
#       cidr_blocks = "0.0.0.0/0"
#     }
#   ]

#   tags = {
#     Name= "DB-SG"
#   }
# }