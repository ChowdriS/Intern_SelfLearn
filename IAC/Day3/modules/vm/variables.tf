variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "rds_endpoint" {
  description = "RDS endpoint for app DB"
  type        = string
}

variable "db_username" {
  type = string
}
variable "tg_arn" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "git_repo" {
  type = string
}

variable "instance_type" {
  type    = string
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
