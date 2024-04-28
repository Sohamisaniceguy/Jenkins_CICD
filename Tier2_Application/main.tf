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
      version = ">= 5.30"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Tier2App-VPC"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway = true

  tags = {
    Name = "Tier2App"
    Terraform = "true"
    Environment = "dev"
  }
}


