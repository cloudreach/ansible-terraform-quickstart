data "aws_vpc" "selected_vpc" {
  id = "${var.bastion_vpc_id}"
}

data "aws_subnet" "selected_subnets" {
  id    = "${element(var.bastion_public_subnets,count.index)}"
  count = 1
}

// Figure out how to only select new AMI if specifically upgrading
data "aws_ami" "selected_ami" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server*",
    ]
  }
}

data "aws_route53_zone" "selected_zone" {
  zone_id = "${var.bastion_hosted_zone_id}"
  count   = "${var.bastion_setup_dns ? 1 : 0}"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${var.bastion_resource_name_prepend}-profile-${var.bastion_environment}"

  role = "${aws_iam_role.bastion_role.name}"

}

resource "aws_iam_role" "bastion_role" {
  name = "${var.bastion_resource_name_prepend}-${var.bastion_environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_eip" "bastion_eip" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

resource "aws_instance" "bastion" {
  lifecycle {
    ignore_changes = ["ami"]
  }

  ami           = "${data.aws_ami.selected_ami.image_id}"
  instance_type = "${var.bastion_instance_size}"
  key_name      = "${var.bastion_key_name}"
  subnet_id     = "${data.aws_subnet.selected_subnets.0.id}"

  vpc_security_group_ids = [
    "${aws_security_group.bastion_sg.id}",
    "${var.bastion_admin_sg_id}",
  ]

  iam_instance_profile        = "${aws_iam_instance_profile.bastion_profile.name}"
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
  }

  tags = "${merge(var.bastion_additional_tags,map("Name","${var.bastion_resource_name_prepend}-${var.bastion_environment}"))}"
}

resource "aws_security_group" "bastion_sg" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "${var.bastion_resource_name_prepend}-${var.bastion_environment}-"
  description = "${var.bastion_resource_name_prepend} Security Group."
  vpc_id      = "${data.aws_vpc.selected_vpc.id}"

  tags = "${merge(var.bastion_additional_tags,map("Name","${var.bastion_resource_name_prepend}-${var.bastion_environment}"))}"
}

resource "aws_security_group_rule" "bastion_sg_group_rule" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.bastion_sg.id}"
  source_security_group_id = "${element(var.bastion_ssh_groups, count.index)}"
  count                    = "${var.bastion_ssh_groups_count}"
}

resource "aws_security_group_rule" "bastion_sg_cidr_rule" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id = "${aws_security_group.bastion_sg.id}"
  cidr_blocks       = ["${element(var.bastion_ssh_cidrs, count.index)}"]
  count             = "${length(var.bastion_ssh_cidrs)}"
}

resource "aws_security_group_rule" "bastion_sg_rule_outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.bastion_sg.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_route53_record" "bastion_dns" {
  zone_id = "${data.aws_route53_zone.selected_zone.zone_id}"
  name    = "${var.bastion_resource_name_prepend}-${var.bastion_environment}"
  type    = "A"
  records = ["${aws_instance.bastion.public_ip}"]
  ttl     = 300
  count   = "${var.bastion_setup_dns ? 1 : 0}"
}

output "instance_id" {
  value = "${aws_instance.bastion.id}"
}

output "ami" {
  value = "${data.aws_ami.selected_ami.image_id}"
}

output "sg_id" {
  value = "${aws_security_group.bastion_sg.id}"
}
