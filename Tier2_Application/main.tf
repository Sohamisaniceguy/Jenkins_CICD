terraform {

  backend "s3" {
    bucket         = "backend-sohamapp-tf-state"               #Backup Bucket name
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
  source = "./Module/VPC"
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  vpc_cidr = var.vpc_cidr
}



#SG:
module "sg" {
  source = "./Module/security_group"
  vpc_id =  module.vpc.vpc_id

}


#ALB:
module "alb" {
  source        = "./Module/ALB"
  alb_sg_id     = module.sg.alb_sg_id
  public_subnet = module.vpc.public_subnets
  vpc_id        = module.vpc.vpc_id
}

#ASG:
module "asg" {
  source           = "./Module/ASG"
  ec2_sg_id        = module.sg.ec2_sg_id
  target_group_arn = module.alb.target_group_arn
  private_subnets  = slice(module.vpc.private_subnets, 0, 2)
}

#RDS:

