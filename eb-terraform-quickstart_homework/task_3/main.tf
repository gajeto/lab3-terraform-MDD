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
  profile = ...
  ## homework:end
  region = "us-east-1"

  default_tags {
    tags = {
      Topic = "terraform"
      ## homework:start
      Owner = ...
      ## homework:end
    }
  }
}


module "ec2" {
  source = "./ec2"

  ## homework:start
  instance_type = ...
  ## homework:end

  ## homework:start
  public_ssh_key = ...
  ## homework:end

  user_data = filebase64("./scripts/user_data.sh")
}

output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}
