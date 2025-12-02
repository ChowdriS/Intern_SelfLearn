variable "ec2_ami" {
  description = "Amazon Linux 2 AMI for us-west-2"
  default     = "ami-0fa3fe0fa7920f68e"
}

variable "db_name" {
  default = "exampledb"
}

variable "db_user" {
  default = "exampleuser"
}

variable "db_pass" {
  default = "examplepass"
}
