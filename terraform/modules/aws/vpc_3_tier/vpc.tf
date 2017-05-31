data "aws_availability_zones" "all_azs" {}

data "aws_caller_identity" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = "${merge(var.additional_tags, map("Name", var.vpc_name))}"
}

resource "aws_internet_gateway" "int_gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(var.additional_tags, map("Name", var.vpc_name))}"
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.${var.region}.s3"

  route_table_ids = [
    "${aws_route_table.data_route_table.*.id}",
    "${aws_route_table.private_route_table.*.id}",
  ]

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action":
        "s3:*"
      ,
      "Resource":
        "arn:aws:s3:::*"

    }
  ]
}
POLICY
}

resource "aws_security_group" "administration_group" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "admin-${var.vpc_name}-"
  description = "Administration Security Group"
  vpc_id      = "${aws_vpc.main.id}"
  tags        = "${merge(var.additional_tags, map("Name", "admin-${var.vpc_name}"))}"
}

resource "aws_vpn_gateway" "private_gateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(var.additional_tags, map("Name", "PrivateGateway-${var.vpc_name}"))}"
}

resource "aws_vpc_peering_connection" "peering_connection" {
  count = "${length(var.peering_connection_vpc_ids)}"

  peer_owner_id = "${data.aws_caller_identity.current.account_id}"
  peer_vpc_id   = "${element(var.peering_connection_vpc_ids, count.index)}"
  vpc_id        = "${aws_vpc.main.id}"
  auto_accept   = true

  tags {
    Name = "${var.vpc_name} to ${element(var.peering_connection_vpc_ids, count.index)}"
  }
}


output "all_azs" {
  value = [
    "${data.aws_availability_zones.all_azs.names.*}",
  ]
}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "internet_gateway" {
  value = "${aws_internet_gateway.int_gw.id}"
}

output "private_gateway" {
  value = "${aws_vpn_gateway.private_gateway.id}"
}

output "s3_endpoint" {
  value = "${aws_vpc_endpoint.s3_endpoint.id}"
}

output "admin_sg" {
  value = "${aws_security_group.administration_group.id}"
}

output "selected_azs" {
  //  Replace with slice to keep dynamic with az_count.. should be in next release
  value = [
    "${data.aws_availability_zones.all_azs.names[0]}",
    "${data.aws_availability_zones.all_azs.names[1]}",
  ]
}
