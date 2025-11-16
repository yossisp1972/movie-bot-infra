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