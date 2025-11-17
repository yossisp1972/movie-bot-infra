terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
    }

    backend "s3" {
        bucket         = "movie-bot-tfstate"
        key            = "global/s3/terraform.tfstate"
        region         = "us-east-1"
        use_lockfile = "movie-bot-tflock" # optional, for state locking
        encrypt        = true
  }
}