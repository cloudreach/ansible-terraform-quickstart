variable "access_key" {}
variable "secret_key" {}

variable "region" {
    default = "us-east-1"
}
variable "ami" {
	default = "ami-49c9295f"
}

variable "instance_size" {
	default = "t2.micro"
}

variable "key_name" {
	default = "terraform"
}

variable "subnet_id" {}
variable "vpc_id" {}
variable "ssh_cidr" {}
variable "sandbox_owner" {}