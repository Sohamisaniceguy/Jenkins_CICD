terraform {

    backend "s3" {
    bucket         = "backend-sohamapp-tf-state" #Backup Bucket name
    key            = "learn-terraform/Tier2/terraform.tfstate" #Backup 
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.48.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Tier2App-VPC"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway = true

  tags = {
    Name = "Tier2App-VPC"
    Terraform = "true"
    Environment = "dev"
  }

  public_subnet_tags = {            #Specific for Subnet , different from VPC
    Name = "Tier2App-Pub-Subnet"
  }

  private_subnet_tags = {            #Specific for Subnet , different from VPC
    Name = "Tier2App-Priv-Subnet"
  }
}


#SG:
# module "sg" {
#   source = "./Module/security_group"
# }






#ALB:
module "alb" {
  source         = "./Module/ALB"
  alb_sg_id      = module.alb_sg.security_group_id
  public_subnet  = module.vpc.public_subnets
  vpc_id         = module.vpc.vpc_id
}

#ASG:
module "asg" {
  source         = "./Module/ASG"
  ec2_sg_id = module.ec2_sg.security_group_id
  target_group_arn = module.alb.target_group_arn
  private_subnets = slice(module.vpc.private_subnets,0,2)
}

