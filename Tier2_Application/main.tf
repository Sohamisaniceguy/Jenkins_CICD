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
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "SecurityG-EC2"
  description = "Security group for EC2 Server"
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
    Name= "EC-SG"
  }
}




#EC2:
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "EC2-Server"

  instance_type          = var.instance_type
  #key_name               = 
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.private_subnets
#   associate_public_ip_address = true
#   user_data = file("jenkins-installation.sh")
  availability_zone = data.aws_availability_zones.azs.names

  tags = {
    Name = "EC2-server"
    Terraform   = "true"
    Environment = "dev"
  }
}

