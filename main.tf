#creating vpc
resource "aws_vpc" "MyVPC" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "My_VPC"
  }
}

#creating public subnet
resource "aws_subnet" "MyPublicSubnet1" {
  vpc_id                  = aws_vpc.MyVPC.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "MyPublicSubnet"
  }
}

resource "aws_subnet" "MyPublicSubnet2" {
  vpc_id                  = aws_vpc.MyVPC.id
  cidr_block              = var.subnet_cidr_block2
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "MyPublicSubnet2"
  }
}

#creating internet gateway
resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id
  tags = {
    Name = "MyIGW"
  }
}

#creating public route table
resource "aws_route_table" "MyPublicRT1" {
  vpc_id = aws_vpc.MyVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }
  tags = {
    Name = "MyPublicRT"
  }
}

#associating public route table with public subnet1
resource "aws_route_table_association" "MyPublicRTAssociation" {
  subnet_id      = aws_subnet.MyPublicSubnet1.id
  route_table_id = aws_route_table.MyPublicRT1.id
}

resource "aws_route_table_association" "MyPublicRTAssociation2" {
  subnet_id      = aws_subnet.MyPublicSubnet2.id
  route_table_id = aws_route_table.MyPublicRT1.id
}

#creating security group
resource "aws_security_group" "WEB_SG" {
  name        = "WEB_SG"
  description = "WEB_SG"
  vpc_id      = aws_vpc.MyVPC.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WEB_SG"
  }
}

#creating s3 bucket
resource "aws_s3_bucket" "My_S3_Bucket" {
  bucket = "sumeetnirmaleterrafombucket2025"
  tags = {
    Name = "My_S3_Bucket"
  }
}

#creating web server1
resource "aws_instance" "Web_Server1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.WEB_SG.id]
  subnet_id              = aws_subnet.MyPublicSubnet1.id
  user_data              = base64encode(file("userdata.sh"))
  tags = {
    Name = "Web_Server1"
  }
}

#creating web server2
resource "aws_instance" "Web_Server2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.WEB_SG.id]
  subnet_id              = aws_subnet.MyPublicSubnet2.id
  user_data              = base64encode(file("userdata1.sh"))
  tags = {
    Name = "Web_Server2"
  }
}

#creating load balancer
resource "aws_lb" "MyLoadBalancer" {
  name               = "MyLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.WEB_SG.id]
  subnets            = [aws_subnet.MyPublicSubnet1.id, aws_subnet.MyPublicSubnet2.id]
}

#creating target group
resource "aws_lb_target_group" "MyTargetGroup" {
  name        = "MyTargetGroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.MyVPC.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#creating target group attachment
resource "aws_lb_target_group_attachment" "MyTgAttachment" {
  target_group_arn = aws_lb_target_group.MyTargetGroup.arn
  target_id        = aws_instance.Web_Server1.id
  port             = 80
}

#creating target group attachment2
resource "aws_lb_target_group_attachment" "MyTgAttachment2" {
  target_group_arn = aws_lb_target_group.MyTargetGroup.arn
  target_id        = aws_instance.Web_Server2.id
  port             = 80
}

#creating load balancer listener
resource "aws_lb_listener" "MyLBListener" {
  load_balancer_arn = aws_lb.MyLoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.MyTargetGroup.arn
    type             = "forward"
  }
}



