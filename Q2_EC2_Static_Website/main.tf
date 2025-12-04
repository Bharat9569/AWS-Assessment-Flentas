
provider "aws" {
  region = "ap-south-1"
}

variable "prefix" {
  type    = string
  default = "FirstName_Lastname"
}

variable "ssh_key_name" {
  type    = string
  default = "your-keypair-name" # UPDATE this before apply
}

variable "ami_id" {
  type    = string
  default = "ami-0c7d075b3fEXAMPLE" # UPDATE this to a valid Amazon Linux 2 AMI in your region
}


resource "aws_vpc" "site_vpc" {
  cidr_block = "10.10.0.0/16"
  tags = { Name = "${var.prefix}_site_vpc" }
}

resource "aws_subnet" "site_public" {
  vpc_id = aws_vpc.site_vpc.id
  cidr_block = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = { Name = "${var.prefix}_site_public" }
}

resource "aws_internet_gateway" "site_igw" {
  vpc_id = aws_vpc.site_vpc.id
  tags = { Name = "${var.prefix}_site_igw" }
}

resource "aws_route_table" "site_public_rt" {
  vpc_id = aws_vpc.site_vpc.id
  route { cidr_block = "0.0.0.0/0", gateway_id = aws_internet_gateway.site_igw.id }
  tags = { Name = "${var.prefix}_site_public_rt" }
}

resource "aws_route_table_association" "site_public_assoc" {
  subnet_id = aws_subnet.site_public.id
  route_table_id = aws_route_table.site_public_rt.id
}


resource "aws_security_group" "site_sg" {
  name        = "${var.prefix}_site_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.site_vpc.id
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
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  tags = { Name = "${var.prefix}_site_sg" }
}


resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.site_public.id
  key_name      = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.site_sg.id]
  tags = { Name = "${var.prefix}_resume_ec2" }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl enable nginx
              cat > /usr/share/nginx/html/index.html << 'HTML'
              <!doctype html><html><head><meta charset="utf-8"><title>Resume</title></head><body><h1>My Resume</h1><p>Name: Your Name</p><p>Role: Student</p></body></html>
              HTML
              systemctl start nginx
              EOF
}

output "public_ip" { value = aws_instance.web.public_ip }