terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  ## homework:start
  profile = "default"
  ## homework:end
  region = "eu-central-1"

  default_tags {
    tags = {
      Topic = "terraform"
      ## homework:start
      Owner = "gajeto"
      ## homework:end
    }
  }
}

resource "aws_s3_bucket" "bucket_mdd_gajeto" {
  bucket = "test-bucket-mdd"

  tags = {
    Name        = "test-bucket"
    Environment = "Dev"
  }
}
