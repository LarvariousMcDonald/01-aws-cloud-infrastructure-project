
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
}

module "nat_instance" {
  source = "../../modules/nat-instance"

  project_name       = var.project_name
  public_subnet_id   = module.vpc.public_subnet_ids[0]
  nat_security_group = module.security.nat_security_group_id
  instance_profile   = module.iam.instance_profile_name
}

module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security.alb_security_group_id
  vpc_id            = module.vpc.vpc_id
}

module "compute" {
  source = "../../modules/compute"

  project_name        = var.project_name
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security.app_security_group_id
  instance_profile    = module.iam.instance_profile_name
  target_group_arn    = module.alb.target_group_arn
  instance_type       = var.instance_type
}

module "storage" {
  source = "../../modules/storage"

  project_name = var.project_name
}

module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  asg_name     = module.compute.asg_name
}