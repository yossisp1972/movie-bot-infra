# movie-bot-infra

Terraform code to provision an EKS cluster for the Movie Bot project.

## Usage

1. Install [Terraform](https://www.terraform.io/downloads.html) and configure your AWS credentials.
2. Run `terraform init` to initialize the project.
3. Run `terraform apply` to provision the infrastructure.

## Variables
- `aws_region`: AWS region (default: us-east-1)
- `cluster_name`: EKS cluster name (default: movie-bot-eks)
- `node_instance_type`: EC2 instance type for nodes (default: t3.small)

## Outputs
- `cluster_name`: Name of the EKS cluster
- `kubeconfig`: Kubeconfig for accessing the cluster
- `cluster_endpoint`: API endpoint for the cluster
