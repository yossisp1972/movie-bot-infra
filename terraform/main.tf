provider "aws" {
    region = var.region
}
module  "vpc" {
    source = "./modules/vpc"
    vpc_name = var.vpc_name
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name =  var.vpc_name
    }
}