variable "access_key" {}

variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "environment" {
  default = "tf-training"
}

variable "backup" {
  default = "false"
}

variable "retention" {
  default = "7" 
}

variable "global_tags" {
  type = "map"

  default = {
    "Customer"  = "relus"
    "CreatedBy" = "terraform"
    "Term"      = "temp"
  }
}

variable "shared_keypair" {
  default = "frizvi"
}

variable "bastion_whitelist_cidrs" {
  type = "list"

  default = [
    "50.235.124.155/32", # Relus ATL office
    "71.230.35.166/32",  # Frizvi ip
    "181.142.172.0/32",  # Camilo IP
  ]
}
