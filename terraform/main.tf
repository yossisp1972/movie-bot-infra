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
    source = "terraform-aws-modules/eks/aws"
    version = "18.0.0"

    cluster_name    = var.cluster_name
    cluster_version = var.cluster_version
    subnet_ids      = module.vpc.private_subnets
    vpc_id          = module.vpc.vpc_id

    eks_managed_node_groups = {
        eks_nodes = {
            desired_capacity = 2
            max_capacity     = 3
            min_capacity     = 1

            instance_type = "t1.small"
            key_name      = var.key_name

            tags = {
                Name = "eks-node"
            }
        }
    }
}