provider "aws" {
    region = var.region
}
module  "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Name        = var.vpc_name
    Environment = "dev"
  }
  
    
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.33"
  
  # addons = {
  #   coredns                = {}
  #   eks-pod-identity-agent = {
  #     before_compute = true
  #   }
  #   kube-proxy             = {}
  #   vpc-cni                = {
  #     before_compute = true
  #     resolve_conflicts  = "OVERWRITE"
  #   }
  # }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets
  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    workers = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}