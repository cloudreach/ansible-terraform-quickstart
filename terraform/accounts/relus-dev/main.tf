terraform {
  backend "s3" {
    bucket     = "relus-terraform"
    key        = "accounts/relus-dev/terraform.tfstate"
    region     = "us-east-1"
    lock_table = "relus-terraform-1"
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "vpc" {
  source               = "../../modules/aws/vpc_3_tier"
  vpc_name             = "tf-training"
  vpc_cidr             = "10.14.0.0/20"
  public_subnet_cidrs  = ["10.14.0.0/23", "10.14.2.0/23"]
  private_subnet_cidrs = ["10.14.4.0/22", "10.14.8.0/22"]
  data_subnet_cidrs    = ["10.14.12.0/25", "10.14.12.128/25"]
  additional_tags      = "${var.global_tags}"
  region               = "${var.region}"
}

module "bastion_linux" {
  source                  = "../../modules/aws/bastion_linux"
  bastion_vpc_id          = "${module.vpc.vpc_id}"
  bastion_environment     = "${var.environment}"
  bastion_additional_tags = "${var.global_tags}"
  bastion_key_name        = "frizvi"
  bastion_public_subnets  = "${module.vpc.public_subnets}"
  bastion_ssh_cidrs       = "${var.bastion_whitelist_cidrs}"
  bastion_admin_sg_id     = "${module.vpc.admin_sg}"
  bastion_setup_dns       = false
}