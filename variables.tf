variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "A /16 CIDR range the VPC will use"
  default = "192.163.0.0/16"
}

variable "mysql_cidr_block" {
  description = "A /16 CIDR range the MySQL Subnet will use"
  default = "192.163.1.0/24"
}

variable "wp_cidr_block" {
  description = "A /16 CIDR range the WordPress Subnet will use"
  default = "192.163.0.0/24"
}

variable "mysql_ami_id" {
  description = "AMI ID for MySQL"
  default = "ami-f96e3bef"
}

variable "wp_ami_id" {
  description = "AMI ID for WordPress"
  default = "ami-376c5f4c"
}
