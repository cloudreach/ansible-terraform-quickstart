variable "region" {}

variable "az_count" {
  default = 2
}

variable "vpc_name" {
  type = "string"
}

variable "vpc_cidr" {}

variable "data_subnet_cidrs" {
  type    = "list"
  default = []
}

variable "public_subnet_cidrs" {
  type    = "list"
  default = []
}

variable "private_subnet_cidrs" {
  type    = "list"
  default = []
}

variable "additional_tags" {
  type    = "map"
  default = {}
}

variable "peering_connection_vpc_ids" {
  type = "list"
  default = []
}