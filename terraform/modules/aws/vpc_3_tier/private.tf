resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${coalesce(var.private_subnet_cidrs[count.index],cidrsubnet(var.vpc_cidr, 8, 2))}"
  availability_zone = "${element(data.aws_availability_zones.all_azs.names,count.index)}"

  tags = "${merge(var.additional_tags, map("Name", "Private-${count.index}"))}"

  count = "${var.az_count}"
}

resource "aws_route_table" "private_route_table" {
  vpc_id           = "${aws_vpc.main.id}"
  propagating_vgws = ["${aws_vpn_gateway.private_gateway.id}"]

  tags = "${merge(var.additional_tags, map("Name", "Private"))}"
}

resource "aws_route" "private_route_internet" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
  depends_on             = ["aws_route_table.private_route_table", "aws_nat_gateway.nat_gw"] # https://github.com/hashicorp/terraform/issues/7527
}

resource "aws_route_table_association" "private_route_table_assoc" {
  subnet_id      = "${element(aws_subnet.private_subnet.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private_route_table.*.id,count.index)}"
  count          = "${var.az_count}"
}

output "private_subnets" {
  value = [
    "${aws_subnet.private_subnet.*.id}",
  ]
}
