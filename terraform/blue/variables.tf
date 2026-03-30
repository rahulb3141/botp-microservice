variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}


##########################################
# EKS CONNECTION DETAILS
##########################################

variable "eks_cluster_endpoint" {
  description = "EKS API server endpoint URL"
  type        = string
  default     = "https://3AD1032DF45AF30B3D9A36B5523ACC00.gr7.us-east-1.eks.amazonaws.com"
}

variable "eks_cluster_ca" {
  description = "Base64 CA data of the EKS cluster"
  type        = string
  default     = <<EOF

LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVkRFdEZMVWJvUWd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBek1qY3hNakl5TXpsYUZ3MHpOakF6TWpReE1qSTNNemxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURDV3hLMGI3R2lHL0laaDZQL0Qvdi9ETFZabGc2QU9MczlVTlFUVXc0NC9KOXhsQnh3K1NQYUVzSUoKMXUybzFpUFkvS2gyQzI2VUNDeGdKTExCZkxpNkRkakJWMjExN3lSYjllWTlyYnVIVWxZbkdVdUd2L1g2U1g2dQowZmowaUsyM2hxZnJ3OXNVeWpSWldsREl5eGNObnJHM3VpL3NwR0Z3YmhPRXlqMWZXWGdMV2FoaTI4MllueHNsCk5Fc1RlSjAvL1hEY2RVdDAyZjM0akVYbFRsWVZRNEUxUDQwZ255V2oyRk1jUmtnTVVSK3dwZVBVL3VaeUpwTnkKWDZHYUJ2L054VVhTNFlNS1NpT1JsTDQxV2pEM1BpRkFRbnMxa0RyQXZKMHdNN21iWWJadnpaUkwvL3FWNFh3SQpCNVZJRWNFcXg5VEtWK0l2ZjJiNHFPeHRGWXhqQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJURnVwbTU4YjRDZlYvR2hzM29lWkVRaXhFQ0tUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQkFhZzJIOFl6Kwo3V1lrYVRYSzJXUEJQRTdCL2ZqdmxiQ3BHYklleFdQUmRrMkptWExOazArYkpLUFJEVVl3ZWxBMUQva1o0Sm10CmpCSTYyU21BYkFKQmw4Zzl6Vk80ejI1M0JtVlFmTnQvN0FFUS8wVHl5NFk2Qm1SQWNSWkZXNVRRYjI2N3NFOWwKRDhqWHl1ZG05VjI1amdkZk1OTHpEWm5zL0hWOGVIMllRTE1hckpxYzl1Rlk1TkFCOTVQWVBnR0ZXZ3BYTHJHTApLUFVwbDNMQ1M2YzhvMlpyc2tleWZIaHkrdmdUMVNTa3lGa1R0RmtIemd5bjVSWkdYbDNlcDllNExJWTZON1MyCldXYmtzMzhIeFhRb2RFL0JSMFgrM29lOWxuYWdCY1hmcGI3b1BUcUNYTlg0WlpNYTV0SU9XamlmYzltT3FpUGgKaVNHV25RWTk3V1oyCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
EOF
}


variable "eks_token" {
  description = "EKS authentication token"
  type        = string
  sensitive   = true
  default     = "k8s-aws-v1.k8s-aws-v1.aHR0cHM6Ly9zdHMudXMtZWFzdC0xLmFtYXpvbmF3cy5jb20vP0FjdGlvbj1HZXRDYWxsZXJJZGVudGl0eSZWZXJzaW9uPTIwMTEtMDYtMTUmWC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBNVdVSlRQNjZEWDI3SkJUSyUyRjIwMjYwMzMwJTJGdXMtZWFzdC0xJTJGc3RzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNjAzMzBUMTAyMjUzWiZYLUFtei1FeHBpcmVzPTYwJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCUzQngtazhzLWF3cy1pZCZYLUFtei1TaWduYXR1cmU9ZmNlNzc4ZTAzOTNiZTVjYWEwMDk5MGVmNWUxNmUyNDRhOTIzODVkOGJiOWNhMmNhMzA0OTBlZTBhMDhkOTk4NQ"
}



