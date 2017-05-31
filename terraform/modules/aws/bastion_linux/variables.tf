variable "bastion_vpc_id" {}

variable "bastion_instance_size" {
  default = "t2.micro"
}

variable "bastion_key_name" {}

variable "bastion_ssh_cidrs" {
  type    = "list"
  default = []
}

variable "bastion_ssh_groups" {
  type    = "list"
  default = []
}

variable "bastion_ssh_groups_count" {
  default = 0
}

variable "bastion_admin_sg_id" {}

variable "bastion_public_subnets" {
  type = "list"
}

variable "bastion_environment" {}

variable "bastion_additional_tags" {
  type = "map"
}

variable "bastion_resource_name_prepend" {
  default = "bastion-linux"
}

variable "bastion_hosted_zone_id" {
  default = ""
}

variable "bastion_setup_dns" {
  default = false
}
