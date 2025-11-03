resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.web_sg]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier         = "terraform-2tier-rds"
  allocated_storage  = 20
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = var.instance_class
  username           = var.db_username
  password           = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.name
  publicly_accessible = false
  skip_final_snapshot = true
  db_name = "appdb"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "terraform-2tier-rds"
  }
}
