terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    ## homework:start
    bucket = "thisisanotherepojusttotest-gustavosoyoy-terraform-state"
    key = "8569ef14-0651-472d-b9c0-998456429e4c"
    region = "us-east-1"
    ## homework:end
    # use_lockfile = true
    encrypt    = true
    kms_key_id = "arn:aws:kms:us-east-1:815254799362:key/8569ef14-0651-472d-b9c0-998456429e4c"
  }
}

provider "aws" {
  ## homework:start
  ## homework:end
  region = "us-east-1"

  default_tags {
    tags = {
      Topic = "terraform"
      ## homework:start
      Owner = "gajeto"
      ## homework:end
    }
  }
}

resource "aws_s3_bucket" "backend_bucket_task2" {
  bucket = "backend-bucket-task2"

  tags = {
    Name        = "backend-bucket"
    Environment = "Dev"
  }
}
