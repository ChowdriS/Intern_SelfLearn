resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = "terraform-2tier-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "terraform-2tier-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnet_cidrs : cidr => idx
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, each.value)

  tags = {
    Name = "public-subnet-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for idx, cidr in var.private_subnet_cidrs : cidr => idx
  }

  cidr_block = each.key
  vpc_id     = aws_vpc.this.id
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, each.value)

  tags = {
    Name = "private-subnet-${each.value}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
    
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

data "aws_availability_zones" "available" {}


