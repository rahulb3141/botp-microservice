##########################################
# PROVIDERS
##########################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
  }
}

provider "aws" {
  # Configuration options
}
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}
provider "kubernetes" {
  # Configuration options
}


##########################################
# VPC (VPC for Blue)
##########################################

resource "aws_vpc" "blue" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "blue-vpc"
    env  = "blue"
  }
}

resource "aws_subnet" "blue_public" {
  count                   = 2
  vpc_id                  = aws_vpc.blue.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "blue-public-${count.index}"
    env  = "blue"
  }
}

resource "aws_internet_gateway" "blue" {
  vpc_id = aws_vpc.blue.id

  tags = {
    Name = "blue-igw"
    env  = "blue"
  }
}

resource "aws_route_table" "blue_public" {
  vpc_id = aws_vpc.blue.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.blue.id
  }

  tags = {
    Name = "blue-public-rt"
    env  = "blue"
  }
}

resource "aws_route_table_association" "blue_public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.blue_public[count.index].id
  route_table_id = aws_route_table.blue_public.id
}


##########################################
# SECURITY GROUP
##########################################

resource "aws_security_group" "blue_sg" {
  name        = "blue-sg"
  description = "Security group for Blue environment"
  vpc_id      = aws_vpc.blue.id

  ingress {
    description = "Allow HTTP from anywhere"
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
    Name = "blue-sg"
    env  = "blue"
  }
}


##########################################
# KUBERNETES NAMESPACE
##########################################

resource "kubernetes_namespace" "blue" {
  metadata {
    name = "blue"
  }
}
