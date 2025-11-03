variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public Subnets CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private Subnets CIDRs"
  type        = list(string)
}
