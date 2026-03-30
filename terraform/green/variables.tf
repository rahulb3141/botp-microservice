variable "region" {
  description = "AWS region for Blue environment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR for Blue environment"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]
}


