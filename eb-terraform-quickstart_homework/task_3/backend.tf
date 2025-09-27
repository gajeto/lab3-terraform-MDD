terraform {
  backend "s3" {
    ## homework:start
    bucket = "task3-backend-gajeto-terraform-state"
    key = "6af25d02-c1fa-4895-ad07-abb22b336d92"
    region = "us-east-1"
    ## homework:end
    # use_lockfile = true
    encrypt    = true
    kms_key_id = "arn:aws:kms:us-east-1:815254799362:key/6af25d02-c1fa-4895-ad07-abb22b336d92"
  }
}
