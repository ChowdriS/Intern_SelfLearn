variable "region" {
    type = string
  description = "AWS region"
}

variable "vpc_cidr" {
  type = string 
  description = "VPC CIDR block"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "db_name" {
    type = string
  description = "Database name"
}


variable "db_username" {
  type = string
  description = "Database username"
}

variable "db_password" {
  type = string
  description = "Database password"
  sensitive   = true
}

variable "db_instance_class" {
    type = string
  description = "RDS instance class"
}

variable "git_repo" {
    type = string
  description = "Git repository URL for app code"
}

variable "instance_type" {
    type = string
  description = "EC2 instance type"
}

variable "ingress_rules" {
  description = "Ingress rules for security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "Egress rules for security group"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
