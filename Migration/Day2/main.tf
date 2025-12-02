provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
 
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
 
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


data "aws_iam_role" "aws-ec2-mgn" {
  name = "aws-ec2-mgn"
}

resource "aws_iam_instance_profile" "mgn_profile" {
  name = "mgn-instance-profile"
  role = data.aws_iam_role.aws-ec2-mgn.name
}



# VPC + SUBNETS

resource "aws_vpc" "chow3_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "chow3-vpc"
  }
}

resource "aws_subnet" "chow3_public_subnet" {
  vpc_id                  = aws_vpc.chow3_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "chow3-public-subnet"
  }
}

resource "aws_subnet" "chow3_private_subnet" {
  vpc_id     = aws_vpc.chow3_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "chow3-private-subnet"
  }
}

resource "aws_internet_gateway" "chow3_igw" {
  vpc_id = aws_vpc.chow3_vpc.id
  tags = {
    Name = "chow3-igw"
  }
}

resource "aws_route_table" "chow3_public_rt" {
  vpc_id = aws_vpc.chow3_vpc.id
  tags = {
    Name = "chow3-public-rt"
  }
}

resource "aws_route" "chow3_public_route" {
  route_table_id         = aws_route_table.chow3_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.chow3_igw.id
}

resource "aws_route_table_association" "chow3_public_assoc" {
  subnet_id      = aws_subnet.chow3_public_subnet.id
  route_table_id = aws_route_table.chow3_public_rt.id
}

# NAT + PRIVATE ROUTE TABLE

resource "aws_eip" "chow3_nat_eip" {
  tags = {
    Name = "chow3-nat-eip"
  }
}

resource "aws_nat_gateway" "chow3_nat_gw" {
  subnet_id     = aws_subnet.chow3_public_subnet.id
  allocation_id = aws_eip.chow3_nat_eip.id
  tags = {
    Name = "chow3-nat-gw" 
  }
}

resource "aws_route_table" "chow3_private_rt" {
  vpc_id = aws_vpc.chow3_vpc.id
  tags = {
    Name = "chow3-private-rt"
  }
}

resource "aws_route" "chow3_private_route" {
  route_table_id         = aws_route_table.chow3_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.chow3_nat_gw.id
}

resource "aws_route_table_association" "chow3_private_assoc" {
  subnet_id      = aws_subnet.chow3_private_subnet.id
  route_table_id = aws_route_table.chow3_private_rt.id
}

# SECURITY GROUPS

resource "aws_security_group" "chow3_nginx_sg" {
  vpc_id = aws_vpc.chow3_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["202.83.25.24/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "chow3-nginx-sg"
  }
}

data "aws_key_pair" "mgn_pair" {
  key_name = "ssh_pair"
}

resource "aws_security_group" "chow3_flask_sg" {
  vpc_id = aws_vpc.chow3_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["202.83.25.24/32"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.chow3_nginx_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "chow3-flask-sg"
  }
}

resource "aws_security_group" "chow3_db_sg" {
  vpc_id = aws_vpc.chow3_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.chow3_flask_sg.id]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.chow3_flask_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "chow3-db-sg"
  }
}

# EC2 MySQL

resource "aws_instance" "chow3_mysql" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.large"
  subnet_id                   = aws_subnet.chow3_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.chow3_db_sg.id]
  key_name                    = data.aws_key_pair.mgn_pair.key_name
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/userdata/mysql-data.tpl", {
    db_name = var.db_name
    db_user = var.db_user
    db_pass = var.db_pass
  })

  tags = { Name = "chow3-mysql" }
}


# EC2 – Flask server

resource "aws_instance" "chow3_flask" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.chow3_public_subnet.id
  vpc_security_group_ids = [aws_security_group.chow3_flask_sg.id]
  key_name               = data.aws_key_pair.mgn_pair.key_name

  user_data = templatefile("${path.module}/userdata/flask-data.tpl", {
    db_name   = var.db_name
    db_user   = var.db_user
    db_pass   = var.db_pass
    db_host   = aws_instance.chow3_mysql.private_ip
    app_code  = file("${path.module}/app.py")
  })

  depends_on = [aws_instance.chow3_mysql]

  tags = { Name = "chow3-flask" }
}


# EC2 – NGINX frontend

resource "aws_instance" "chow3_nginx" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.large"
  subnet_id              = aws_subnet.chow3_public_subnet.id
  vpc_security_group_ids = [aws_security_group.chow3_nginx_sg.id]
  key_name               = data.aws_key_pair.mgn_pair.key_name
  iam_instance_profile        = aws_iam_instance_profile.mgn_profile.name
  user_data = templatefile("${path.module}/userdata/nginx-data.tpl", {
    flask_ip   = aws_instance.chow3_flask.private_ip
    nginx_conf = file("${path.module}/nginx.conf")
  })

  depends_on = [aws_instance.chow3_flask,aws_instance.chow3_mysql]

  tags = { Name = "chow3-nginx" }
}


# OUTPUT

output "frontend_url" {
  value = aws_instance.chow3_nginx.public_ip
}

output "backend" {
  value = aws_instance.chow3_flask.public_ip
}

output "db" {
  value = aws_instance.chow3_mysql.public_ip
}