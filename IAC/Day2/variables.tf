variable "region" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "availability_zone_us_east_1" {
  type = list(string)
}

variable "vpc_cidr_block" {
  type    = string
}