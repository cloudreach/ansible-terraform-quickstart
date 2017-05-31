terraform {
  backend "s3" {
    bucket     = "relus-terraform2"
    key        = "environments/training/terraform.tfstate"
    region     = "us-east-1"
    lock_table = "relus-terraform2"
  }
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}


//data "aws_ami" "selected_ami" {
//  most_recent = true
//
//  filter {
//    name = "name"
//
//    values = [
//      "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server*",
//    ]
//  }
//}

variable "your_name" {
  default = "ferzan"
}

resource "aws_security_group" "training_sg" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.your_name}-"
  description = "${var.your_name} SG"
  vpc_id      = "vpc-544b9f2d"

  tags = "${merge(var.global_tags,map("Name","${var.your_name}-${var.environment}"))}"
}

resource "aws_security_group_rule" "training_sg_group_rule" {
  type      = "ingress"
  from_port = 555
  to_port   = 555
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.training_sg.id}"
  cidr_blocks = ["${var.bastion_whitelist_cidrs}"]
//  count                    = "${var.bastion_ssh_groups_count}"
}
