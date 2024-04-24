terraform {

    backend "s3" {
    bucket         = "backend-sohamapp-tf-state" #Backup Bucket name
    key            = "learn-terraform/Jenkins/terraform.tfstate" #Backup 
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


# VPC:

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Jenkins-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets

  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  tags = {
    Name = "Jenkins-Vpc"
    Terraform = "true"
    Environment = "dev"
  }

  public_subnet_tags = {            #Specific for Subnet , different from VPC
    Name = "Jenkins-Pub-Subnet"
  }
}

# SG:
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "SecurityG-Jenkins"
  description = "Security group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
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
    Name= "Sg-Jenkins"
  }
}


# EC2:
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-Server"

  instance_type          = var.instance_type
  #key_name               = 
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data = file("jenkins-installation.sh")
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "Jenkins-server"
    Terraform   = "true"
    Environment = "dev"
  }
}


