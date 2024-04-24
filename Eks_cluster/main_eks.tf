terraform {

    backend "s3" {
    bucket         = "backend-sohamapp-tf-state" #Backup Bucket name
    key            = "learn-terraform/EKS/terraform.tfstate" #Backup 
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true #Because we are deploying the EKS clusters in private subnet
  single_nat_gateway   = true # will be deployed in the first public subnet. If it was false, there would be Natgateway in each subnet.

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = 1
  }
}



# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "EKS-cluster"
  cluster_version = "1.29"

  vpc_id = module.vpc.vpc_id
  subnet_ids =module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.micro"]
      # capacity_type  = "SPOT"
    }
  }

  # # Cluster access entry
  # # To add the current caller identity as an administrator
  # enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   # One access entry with a policy associated
  #   example = {
  #     kubernetes_groups = []
  #     principal_arn     = "arn:aws:iam::123456789012:role/something"

  #     policy_associations = {
  #       example = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #         access_scope = {
  #           namespaces = ["default"]
  #           type       = "namespace"
  #         }
  #       }
  #     }
  #   }
  # }

  tags = {
    name = "MY-EKS"
    Environment = "dev"
    Terraform   = "true"
  }
}




# locals {
#   region = "us-east-1"
#   name   = "soham-cluster"
#   vpc_cidr = "10.0.0.0/16"
#   azs      = ["us-east-1a", "us-east-1b"]
#   public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
#   private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
#   intra_subnets   = ["10.0.5.0/24", "10.0.6.0/24"]
#   tags = {
#     Example = local.name
#   }
# }

# #VPC Config

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   version = "~> 4.0"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   private_subnets = local.private_subnets
#   public_subnets  = local.public_subnets
#   intra_subnets  = local.intra_subnets

#   enable_nat_gateway = true
# #   enable_vpn_gateway = true

#   public_subnet_tags = {
#     Name = "VPC-Public"
#   }

#   private_subnet_tags = {
#     Name = "VPC-Private"
#   }

#   intra_subnet_tags = {
#     Name = "VPC-Intra"
#   }
# }


# # EKS Config

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 20.0"

#   cluster_name    = local.name
#   cluster_version = "1.29"

#   cluster_endpoint_public_access  = true

#   cluster_addons = {
#     coredns = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#     vpc-cni = {
#       most_recent = true
#     }
#   }

#   vpc_id                   = module.vpc.vpc_id
#   subnet_ids               = module.vpc.private_subnets
#   control_plane_subnet_ids = module.vpc.intra_subnets

#   # EKS Managed Node Group(s)
#   eks_managed_node_group_defaults = {
#     ami_type       = "AL2_x86_64"
#     instance_types = ["t2.micro"]

#     attach_cluster_primary_security_group = true
#   }

#   eks_managed_node_groups = {
#     soham-cluster-ng = {
#       min_size     = 1
#       max_size     = 2
#       desired_size = 1

#       instance_types = ["t2.micro"]
#       capacity_type  = "SPOT"

#       tags={
#         ExtraTag="Instance"
#       }
#     }
#   }


#   tags = {
#     Name="EKS-cluster"
#   }
# }