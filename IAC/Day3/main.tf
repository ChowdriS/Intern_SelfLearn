module "vpc" {
  source = "./modules/vpc"

  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "rds" {
  source = "./modules/rds"

  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnets
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  instance_class   = var.db_instance_class
  web_sg = module.vm.security_group_id
}

module "vm" {
  source = "./modules/vm"

  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.public_subnets
  rds_endpoint           = substr(module.rds.endpoint, 0, length(module.rds.endpoint) - 5)
  db_username            = var.db_username
  db_password            = var.db_password
  git_repo               = var.git_repo
  instance_type          = var.instance_type
  ingress_rules          = var.ingress_rules
  egress_rules           = var.egress_rules
  tg_arn                 = module.alb.target_group_arn
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}