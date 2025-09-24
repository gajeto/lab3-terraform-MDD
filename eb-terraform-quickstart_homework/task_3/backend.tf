terraform {
  backend "s3" {
    ## homework:start
    bucket = ...
    key = ...
    region = ...
    ## homework:end
    # use_lockfile = true
    profile    = "ExpertiseBuilding"
    encrypt    = true
    kms_key_id = "a706e211-659a-4c40-b368-88033573f8f7"
  }
}
