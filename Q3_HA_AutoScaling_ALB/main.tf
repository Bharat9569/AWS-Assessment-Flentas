
provider "aws" {
  region = "ap-south-1"
}

variable "prefix" { type=string; default="FirstName_Lastname" }
variable "ssh_key_name" { type=string; default="your-keypair-name" }
variable "ami_id" { type=string; default="ami-0c7d075b3fEXAMPLE" }


resource "aws_vpc" "ha_vpc" {
  cidr_block = "10.20.0.0/16"
  tags = { Name = "${var.prefix}_ha_vpc" }
}

resource "aws_subnet" "public_a" { vpc_id = aws_vpc.ha_vpc.id; cidr_block = "10.20.1.0/24"; availability_zone="ap-south-1a"; map_public_ip_on_launch=true; tags={Name="${var.prefix}_pub_a"} }
resource "aws_subnet" "public_b" { vpc_id = aws_vpc.ha_vpc.id; cidr_block = "10.20.2.0/24"; availability_zone="ap-south-1b"; map_public_ip_on_launch=true; tags={Name="${var.prefix}_pub_b"} }
resource "aws_subnet" "private_a" { vpc_id = aws_vpc.ha_vpc.id; cidr_block = "10.20.3.0/24"; availability_zone="ap-south-1a"; tags={Name="${var.prefix}_priv_a"} }
resource "aws_subnet" "private_b" { vpc_id = aws_vpc.ha_vpc.id; cidr_block = "10.20.4.0/24"; availability_zone="ap-south-1b"; tags={Name="${var.prefix}_priv_b"} }

resource "aws_internet_gateway" "ha_igw" { vpc_id = aws_vpc.ha_vpc.id; tags={Name="${var.prefix}_ha_igw"} }

resource "aws_route_table" "ha_pub_rt" { vpc_id = aws_vpc.ha_vpc.id
  route { cidr_block="0.0.0.0/0"; gateway_id = aws_internet_gateway.ha_igw.id }
  tags={Name="${var.prefix}_ha_pub_rt"} }

resource "aws_route_table_association" "a_pub_assoc" { subnet_id = aws_subnet.public_a.id; route_table_id = aws_route_table.ha_pub_rt.id }
resource "aws_route_table_association" "b_pub_assoc" { subnet_id = aws_subnet.public_b.id; route_table_id = aws_route_table.ha_pub_rt.id }


resource "aws_eip" "ha_nat_eip" { domain="vpc"; tags={Name="${var.prefix}_ha_nat_eip"} }
resource "aws_nat_gateway" "ha_nat" { allocation_id = aws_eip.ha_nat_eip.id; subnet_id = aws_subnet.public_a.id; tags={Name="${var.prefix}_ha_nat"} }

resource "aws_route_table" "ha_priv_rt" { vpc_id = aws_vpc.ha_vpc.id
  route { cidr_block="0.0.0.0/0"; nat_gateway_id = aws_nat_gateway.ha_nat.id }
  tags={Name="${var.prefix}_ha_priv_rt"} }

resource "aws_route_table_association" "a_priv_assoc" { subnet_id = aws_subnet.private_a.id; route_table_id = aws_route_table.ha_priv_rt.id }
resource "aws_route_table_association" "b_priv_assoc" { subnet_id = aws_subnet.private_b.id; route_table_id = aws_route_table.ha_priv_rt.id }


resource "aws_security_group" "alb_sg" {
  name = "${var.prefix}_alb_sg"
  vpc_id = aws_vpc.ha_vpc.id
  ingress { from_port=80; to_port=80; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
  tags={Name="${var.prefix}_alb_sg"}
}

resource "aws_security_group" "instance_sg" {
  name = "${var.prefix}_instance_sg"
  vpc_id = aws_vpc.ha_vpc.id
  ingress { from_port=80; to_port=80; protocol="tcp"; security_groups=[aws_security_group.alb_sg.id] }
  ingress { from_port=22; to_port=22; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }
  egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] }
  tags={Name="${var.prefix}_instance_sg"}
}


resource "aws_lb" "app" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.alb_sg.id]
  tags={Name="${var.prefix}_alb"}
}

resource "aws_lb_target_group" "tg" {
  name     = "${var.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ha_vpc.id
  health_check { path = "/", matcher = "200-399", interval = 30 }
  tags={Name="${var.prefix}_tg"}
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_launch_template" "lt" {
  name_prefix = "${var.prefix}-lt-"
  image_id    = var.ami_id
  instance_type = "t2.micro"
  key_name = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = base64encode(<<-EOF
    
    yum update -y
    amazon-linux-extras install -y nginx1
    systemctl enable nginx
    cat > /usr/share/nginx/html/index.html << 'HTML'
    <!doctype html><html><head><title>ASG Web</title></head><body><h1>ASG instance</h1></body></html>
    HTML
    systemctl start nginx
  EOF)
}


resource "aws_autoscaling_group" "asg" {
  name                      = "${var.prefix}-asg"
  vpc_zone_identifier       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
  min_size = 1
  max_size = 3
  desired_capacity = 1
  target_group_arns = [aws_lb_target_group.tg.arn]
  tag {
    key                 = "Name"
    value               = "${var.prefix}_asg_instance"
    propagate_at_launch = true
  }
}