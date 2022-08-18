provider "aws" {
  region = var.aws_region       # default us-east-1
  access_key=var.aws_access_key
  secret_key=var.aws_secret_key
}

# VPC with Public and Private Subnet
resource "aws_vpc" "wp_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
      Name = "WordPress-VPC"
  }
}

# VPC Internet Gateway
resource "aws_internet_gateway" "wp_gw" {
  vpc_id = aws_vpc.wp_vpc.id

  tags = {
    Name = "WordPress-GateWay"
  }
}

# WordPress Public Subnet
resource "aws_subnet" "wpsubnet" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = var.wp_cidr_block
  map_public_ip_on_launch="true"

  tags = {
    Name = "WordPress-Subnet"
    }
}

# MySQL Private Subnet
resource "aws_subnet" "sqlsubnet" {
  vpc_id     = "${aws_vpc.wp_vpc.id}"
  cidr_block = var.mysql_cidr_block

  tags = {
  Name = "MySQL-Subnet"
  }
}

# Route Table for WordPress VPC
resource "aws_route_table" "wp_rt" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp_gw.id}"
  }

  tags = {
    Name = "WordPress-Route"
  }
}

# Route Table Association for WordPress
resource "aws_route_table_association" "wp_rta" {
  subnet_id      = aws_subnet.wpsubnet.id
  route_table_id = aws_route_table.wp_rt.id
}

# Security Group for WordPress allowing HTTP, SSH, and Public access
resource "aws_security_group" "wp_sg" {
  name        = "WP-SG-${var.aws_region}"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:AWS009
  }

  tags = {
    Name = "WordPress-SG"
  }
}

# Security Group for MySQL server including WordPress SG for ingress to port 3306 (MySQL default)
resource "aws_security_group" "sql_sg" {
  name = "MySQL-SG-${var.aws_region}"
  vpc_id = "${aws_vpc.wp_vpc.id}"

  ingress {
  protocol        = "tcp"
  from_port       = 3306
  to_port         = 3306
  security_groups = ["${aws_security_group.wp_sg.id}"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL-SG"
  }
}

# Instance running MySQL Server 
resource "aws_instance" "mysql_os" {
  ami           = var.mysql_ami_id
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.sqlsubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sql_sg.id}"]

  tags = {
    Name = "MySQL-OS"
  }
}

# Instance running WordPress Server 
resource "aws_instance" "wordpress_os" {
  ami           = var.wp_ami_id
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.wpsubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_sg.id}"]

  depends_on = [aws_instance.mysql_os]

  tags = {
    Name = "WordPress-OS"
  }
}
