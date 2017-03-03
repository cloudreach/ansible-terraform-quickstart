provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "us-east-1"
}

resource "aws_instance" "sandbox" {
    ami = "${var.ami}"
    instance_type = "${var.instance_size}"
    key_name = "${var.key_name}"
    subnet_id = "${var.subnet_id}"
    vpc_security_group_ids = ["${aws_security_group.sandbox_sg.id}" ]
    tags {
    	Name = "ansible-sandbox-${var.sandbox_owner}"
    	Group = "Sandbox"
    }
	associate_public_ip_address = true
	count = 1
}

resource "aws_security_group" "sandbox_sg" {
  	name = "Sandbox_Webserver"
  	description = "Allow inbound on 80,8080 and all outgoing"
 	vpc_id = "${var.vpc_id}"

	ingress {
    	from_port = 22
    	to_port = 22
    	protocol = "TCP"
    	cidr_blocks = ["${var.ssh_cidr}"]
 	}

	egress {
    	from_port = 0
    	to_port = 0
    	protocol = "-1"
    	cidr_blocks = ["0.0.0.0/0"]
	}
}
