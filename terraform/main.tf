provider "aws" {
    region = var.region
}
module  "vpc" {
    vpc_name = var.vpc_name
    source = "./modules/vpc"
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        vpc_name = var.vpc_name
    }
}