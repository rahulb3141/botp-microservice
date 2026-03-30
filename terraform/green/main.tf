##########################################
# PROVIDERS
##########################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
    
}


##########################################
# VPC (Green VPC)
##########################################

resource "aws_vpc" "green" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "green-vpc"
    env  = "green"
  }
}

resource "aws_subnet" "green_public" {
  count                   = 2
  vpc_id                  = aws_vpc.green.id
  cidr_block              = var.public_subnets[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "green-public-${count.index}"
    env  = "green"
  }
}

resource "aws_internet_gateway" "green" {
  vpc_id = aws_vpc.green.id

  tags = {
    Name = "green-igw"
    env  = "green"
  }
}

resource "aws_route_table" "green_public" {
  vpc_id = aws_vpc.green.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.green.id
  }

  tags = {
    Name = "green-public-rt"
    env  = "green"
  }
}

resource "aws_route_table_association" "green_public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.green_public[count.index].id
  route_table_id = aws_route_table.green_public.id
}


##########################################
# SECURITY GROUP
##########################################

resource "aws_security_group" "green_sg" {
  name        = "green-sg"
  description = "Security group for Green environment"
  vpc_id      = aws_vpc.green.id

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
    Name = "green-sg"
    env  = "green"
  }
}


##########################################
# KUBERNETES NAMESPACE (Green)
##########################################

resource "kubernetes_namespace" "green" {
  metadata {
    name = "green"
  }
}


