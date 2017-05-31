resource "aws_subnet" "data_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${coalesce(var.data_subnet_cidrs[count.index],cidrsubnet(var.vpc_cidr, 8, 2))}"
  availability_zone = "${element(data.aws_availability_zones.all_azs.names,count.index)}"

  tags = "${merge(var.additional_tags, map("Name", "Data-${count.index}"))}"

  count = "${var.az_count}"
}

resource "aws_route_table" "data_route_table" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(var.additional_tags, map("Name", "Data"))}"
}

resource "aws_route_table_association" "data_route_table_assoc" {
  subnet_id      = "${element(aws_subnet.data_subnet.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.data_route_table.*.id,count.index)}"

  count = "${var.az_count}"
}

resource "aws_network_acl" "data_nacl" {
  vpc_id     = "${aws_vpc.main.id}"
  subnet_ids = ["${aws_subnet.data_subnet.*.id}"]
  depends_on = ["aws_subnet.data_subnet"]

  //  aws_network_acl_rule is buggy and keeps recreating or erroring out, using inline definition for now and left proper code
  //  commented out below
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = "${aws_subnet.public_subnet.0.cidr_block}"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 200
    action     = "deny"
    cidr_block = "${aws_subnet.public_subnet.1.cidr_block}"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "deny"
    cidr_block = "${aws_subnet.public_subnet.0.cidr_block}"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "deny"
    cidr_block = "${aws_subnet.public_subnet.1.cidr_block}"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = "${merge(var.additional_tags, map("Name", "DataNacl-${var.vpc_name}"))}"
}

//resource "aws_network_acl_rule" "public_subnet" {
//  network_acl_id = "${aws_network_acl.data_nacl.id}"
//  protocol       = "-1"
//  rule_number    = "${(count.index + 1) * 100}"
//  rule_action    = "deny"
//  cidr_block     = "${element(aws_subnet.public_subnet.*.cidr_block, count.index)}"
//  from_port      = 0
//  to_port        = 0
//
//  count = "${length(aws_subnet.public_subnet.*.cidr_block)}"
//}
//
//resource "aws_network_acl_rule" "all" {
//  network_acl_id = "${aws_network_acl.data_nacl.id}"
//  protocol       = "-1"
//  rule_number    = "${(var.az_count + 1) * 100}"
//  rule_action    = "allow"
//  cidr_block     = "0.0.0.0/0"
//  from_port      = 0
//  to_port        = 0
//}
//
//resource "aws_network_acl_rule" "public_subnet_egress" {
//  network_acl_id = "${aws_network_acl.data_nacl.id}"
//  protocol       = "-1"
//  rule_number    = "${(count.index + 1) * 100}"
//  rule_action    = "deny"
//  cidr_block     = "${element(aws_subnet.public_subnet.*.cidr_block, count.index)}"
//  from_port      = 0
//  to_port        = 0
//  egress         = true
//
//  count = "${length(aws_subnet.public_subnet.*.cidr_block)}"
//}
//
//resource "aws_network_acl_rule" "all_egress" {
//  network_acl_id = "${aws_network_acl.data_nacl.id}"
//  protocol       = "-1"
//  rule_number    = "${(var.az_count + 1) * 100}"
//  rule_action    = "allow"
//  cidr_block     = "0.0.0.0/0"
//  from_port      = 0
//  to_port        = 0
//  egress         = true
//}

output "data_subnets" {
  value = [
    "${aws_subnet.data_subnet.*.id}",
  ]
}
