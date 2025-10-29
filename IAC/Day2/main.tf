resource "aws_vpc" "chow3-state-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "chow3-state-vpc"
  }
}

resource "aws_subnet" "chow3-state-vpc-public-subnet-1" {
  vpc_id                  = aws_vpc.chow3-state-vpc.id
  cidr_block              = var.subnets[0]
  availability_zone       = var.availability_zone_us_east_1[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "chow3-public-subnet-1"
  }
}

resource "aws_subnet" "chow3-state-vpc-public-subnet-2" {
  vpc_id                  = aws_vpc.chow3-state-vpc.id
  cidr_block              = var.subnets[1]
  availability_zone       = var.availability_zone_us_east_1[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "chow3-public-subnet-2"
  }
}

resource "aws_subnet" "chow3-state-vpc-private-subnet-1" {
  vpc_id                  = aws_vpc.chow3-state-vpc.id
  cidr_block              = var.subnets[2]
  availability_zone       = var.availability_zone_us_east_1[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "chow3-private-subnet-1"
  }
}

resource "aws_subnet" "chow3-state-vpc-private-subnet-2" {
  vpc_id                  = aws_vpc.chow3-state-vpc.id
  cidr_block              = var.subnets[3]
  availability_zone       = var.availability_zone_us_east_1[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "chow3-private-subnet-2"
  }
}

resource "aws_internet_gateway" "chow3-igw" {
  vpc_id = aws_vpc.chow3-state-vpc.id

  tags = {
    Name = "chow3-igw"
  }
}

resource "aws_eip" "chow3-nat-eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.chow3-igw]

  tags = {
    Name = "chow3-nat-eip"
  }
}

resource "aws_nat_gateway" "chow3-nat-gateway" {
  allocation_id = aws_eip.chow3-nat-eip.id
  subnet_id     = aws_subnet.chow3-state-vpc-public-subnet-1.id

  tags = {
    Name = "chow3-nat-gateway"
  }
}

resource "aws_route_table" "chow3-state-vpc-public-routetable" {
  vpc_id = aws_vpc.chow3-state-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chow3-igw.id
  }

  tags = {
    Name = "chow3-state-vpc-public-routetable"
  }
}

resource "aws_route_table" "chow3-state-vpc-private-routetable" {
  vpc_id = aws_vpc.chow3-state-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.chow3-nat-gateway.id
  }

  depends_on = [aws_nat_gateway.chow3-nat-gateway]

  tags = {
    Name = "chow3-state-vpc-private-routetable"
  }
}

resource "aws_route_table_association" "chow3-public-subnet-1-assoc-to-routetable" {
  subnet_id      = aws_subnet.chow3-state-vpc-public-subnet-1.id
  route_table_id = aws_route_table.chow3-state-vpc-public-routetable.id
}

resource "aws_route_table_association" "chow3-public-subnet-2-assoc-to-routetable" {
  subnet_id      = aws_subnet.chow3-state-vpc-public-subnet-2.id
  route_table_id = aws_route_table.chow3-state-vpc-public-routetable.id
}

resource "aws_route_table_association" "chow3-private-subnet-1-assoc-to-routetable" {
  subnet_id      = aws_subnet.chow3-state-vpc-private-subnet-1.id
  route_table_id = aws_route_table.chow3-state-vpc-private-routetable.id
}

resource "aws_route_table_association" "chow3-private-subnet-2-assoc-to-routetable" {
  subnet_id      = aws_subnet.chow3-state-vpc-private-subnet-2.id
  route_table_id = aws_route_table.chow3-state-vpc-private-routetable.id
}

resource "aws_security_group" "chow3-vm-sg" {
  name   = "chow3-vm-sg"
  vpc_id = aws_vpc.chow3-state-vpc.id

  tags = {
    Name = "chow3-vm-sg"
  }
}

resource "aws_security_group" "chow3-alb-sg" {
  name   = "chow3-alb-sg"
  vpc_id = aws_vpc.chow3-state-vpc.id

  tags = {
    Name = "chow3-alb-sg"
  }
}

resource "aws_security_group_rule" "Allow-inbound-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chow3-vm-sg.id
}

resource "aws_security_group_rule" "Allow-inbound-http-from-alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.chow3-alb-sg.id
  security_group_id        = aws_security_group.chow3-vm-sg.id
}

resource "aws_security_group_rule" "Allow-all-outbound-vm" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chow3-vm-sg.id
}

resource "aws_security_group_rule" "Allow-inbound-http-for-alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chow3-alb-sg.id
}

resource "aws_security_group_rule" "Allow-all-outbound-alb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.chow3-alb-sg.id
}

resource "aws_instance" "chow3-private-vm-1" {
  ami                         = "ami-0360c520857e3138f"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.chow3-state-vpc-private-subnet-1.id
  key_name                     = "chow3"
  vpc_security_group_ids      = [aws_security_group.chow3-vm-sg.id]

 user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "chow3-private-vm-1"
  }

  depends_on = [ aws_nat_gateway.chow3-nat-gateway ]
}

resource "aws_instance" "chow3-private-vm-2" {
  ami                         = "ami-0360c520857e3138f"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.chow3-state-vpc-private-subnet-2.id
  key_name                     = "chow3"
  vpc_security_group_ids      = [aws_security_group.chow3-vm-sg.id]

 user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "chow3-private-vm-2"
  }
  depends_on = [ aws_nat_gateway.chow3-nat-gateway ]
}

resource "aws_instance" "chow3-public-vm-2" {
  ami                         = "ami-0360c520857e3138f"
  instance_type               = "t3.micro"
  key_name                     = "chow3"
  subnet_id                   = aws_subnet.chow3-state-vpc-public-subnet-2.id
  vpc_security_group_ids      = [aws_security_group.chow3-vm-sg.id]
  associate_public_ip_address = true

 user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "chow3-public-vm-2"
  }
}


resource "aws_alb" "chow3-alb" {
  name             = "chow3-alb"
  internal         = false
  security_groups  = [aws_security_group.chow3-alb-sg.id]
  subnets          = [aws_subnet.chow3-state-vpc-public-subnet-1.id, aws_subnet.chow3-state-vpc-public-subnet-2.id]

  tags = {
    Name = "chow3-alb"
  }
}

resource "aws_alb_target_group" "chow3-alb-target-group-1" {
  name     = "chow3-alb-target-group-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.chow3-state-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "chow3-alb-target-group-1"
  }
}

resource "aws_alb_target_group_attachment" "chow3-alb-tg-attachement-1" {
  target_group_arn = aws_alb_target_group.chow3-alb-target-group-1.arn
  target_id        = aws_instance.chow3-private-vm-1.id
}

resource "aws_alb_target_group_attachment" "chow3-alb-tg-attachement-2" {
  target_group_arn = aws_alb_target_group.chow3-alb-target-group-1.arn
  target_id        = aws_instance.chow3-private-vm-2.id
}

resource "aws_alb_listener" "chow3-alb-listener" {
  load_balancer_arn = aws_alb.chow3-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.chow3-alb-target-group-1.arn
  }
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_alb.chow3-alb.dns_name
}
