variable "access_key" {}
variable "secret_key" {}

variable "region" {
    default = "us-east-1"
}

variable "amis" {
    default = {
        us-east-1 = ""
    }
}

variable "instance_size" {
	default = "t2.micro"
}

variable "key_name" {
	default = "terraform"
}

variable "subnet_id" {
	default = ""
}

variable "vpc_id" {
	default = ""
}

variable "zone_id" {
	default = ""
}