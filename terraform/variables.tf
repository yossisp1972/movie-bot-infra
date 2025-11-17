variable "region" {
    description = "AWS region to deploy resources in"
    type        = string
    default     = "us-east-1"
}

variable "vpc_name" {
    description = "The name of the VPC"
    type        = string
    default     = "movie-bot-vpc"
  
}

variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    default     = "movie-bot-cluster"
}

variable "cluster_version" {
    description = "The version of the EKS cluster"
    type        = string
    default     = "1.21"
}

variable "key_name" {
    description = "The name of the key pair to use for the EKS nodes"
    type        = string
    default     = "movie-bot-key"
}
