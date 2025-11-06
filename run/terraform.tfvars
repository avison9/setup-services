region             = "eu-north-1"
vpc_name           = "oraion-vpc"
environment        = "prod"
cidr_block         = "10.10.0.0/16"
availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
public_subnets     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnets    = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
#----------------------------------------------------RDS Variables-----------------------------------------------
identifier              = "oraion-database"
engine                  = "postgres"
engine_version          = "17.2"
instance_class          = "db.m5.large"
allocated_storage       = 200
master_username         = "administrator"
create_random_password  = true
multi_az                = true
backup_retention_period = 14
create_read_replica     = true
#-----------------------------------------------------Bastion Variable-------------------------------------------
bastions = {
  "db-admin" = {
    purpose              = "RDS Admin Access"
    enable_rds_access    = true
    enable_github_runner = false
  }
  "ci-runner" = {
    purpose              = "GitHub Actions Runner"
    enable_rds_access    = true
    enable_github_runner = true
  }
  # "app-access" = {
  #   purpose           = "App Server SSH"
  #   enable_rds_access = false
  #   enable_github_runner = false
  # }
}
github_token = "awiiweioeritreeweioireroiteerw"

