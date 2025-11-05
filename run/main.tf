module "vpc_data_engineering" {
  source             = "../vpc"
  region             = var.region
  vpc_name           = var.vpc_name
  environment        = var.environment
  cidr_block         = var.cidr_block
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  enable_nat_gateway = false
  single_nat_gateway = false
  enable_flow_logs   = true
  default_tags       = { Project = "Oraion Data Services" }
}

# module "vpc_dr_useast2" {
#   source = "./vpc"

#   region              = "us-east-2"
#   vpc_name            = "core-dr"
#   environment         = "dr"
#   cidr_block          = "10.20.0.0/16"
#   availability_zones  = ["us-east-2a", "us-east-2b"]
#   public_subnets      = ["10.20.1.0/24", "10.20.2.0/24"]
#   private_subnets     = ["10.20.11.0/24", "10.20.12.0/24"]
#   enable_nat_gateway  = true
#   single_nat_gateway  = true
# }

module "rds_database" {
  source                     = "../rds"
  region                     = var.region
  identifier                 = var.identifier
  environment                = var.environment
  vpc_id                     = module.vpc_data_engineering.vpc_id
  private_subnet_ids         = module.vpc_data_engineering.private_subnet_ids
  engine                     = var.engine
  engine_version             = var.engine_version
  instance_class             = var.instance_class
  allocated_storage          = var.allocated_storage
  master_username            = var.master_username
  create_random_password     = var.create_random_password
  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
  create_read_replica        = var.create_read_replica
  bastion_security_group_ids = [module.bastions.security_group_id]
  rotate_password            = true
  # app_security_group_ids = [module.app.security_group_id]

  default_tags = { Project = "Oraion Data Services" }
}

# Root module
module "bastions" {
  source                   = "../bastion"
  region                   = var.region
  environment              = var.environment
  bastions                 = var.bastions
  vpc_id                   = module.vpc_data_engineering.vpc_id
  public_subnet_ids        = module.vpc_data_engineering.public_subnet_ids
  rds_sg_id                = module.rds_database.security_group_id
  github_token             = var.github_token
  github_organization_name = var.github_org_name
  rds_endpoint             = module.rds_database.primary_endpoint
  rds_secret_arn           = module.rds_database.secret_arn
}