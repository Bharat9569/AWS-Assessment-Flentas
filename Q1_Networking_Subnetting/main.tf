
provider "aws" {
  region = "ap-south-1"
}

variable "prefix" {
  type    = string
  default = "FirstName_Lastname"
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.prefix}_vpc" }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.prefix}_igw" }
}


resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.prefix}_public_1" }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = { Name = "${var.prefix}_public_2" }
}


resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  tags = { Name = "${var.prefix}_private_1" }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = { Name = "${var.prefix}_private_2" }
}


resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = { Name = "${var.prefix}_nat_eip" }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public1.id
  tags = { Name = "${var.prefix}_nat" }
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.prefix}_public_rt" }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.prefix}_private_rt" }
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}

output "vpc_id" { value = aws_vpc.main.id }
output "public_subnets" { value = [aws_subnet.public1.id, aws_subnet.public2.id] }
output "private_subnets" { value = [aws_subnet.private1.id, aws_subnet.private2.id] }
output "nat_gateway_id" { value = aws_nat_gateway.nat.id }