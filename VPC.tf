# VPC
resource "aws_vpc" "final-project-1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "final-project-1"
  }
}

# SUBNETS
resource "aws_subnet" "final-project-1-public-subnet" {
  vpc_id     = aws_vpc.final-project-1.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
  tags = {
    Name = "final-project-1-public-subnet"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "final-project-1-IGW" {
  vpc_id = aws_vpc.final-project-1.id
  tags = {
    Name = "final-project-1-IGW"
  }
}
# ROUTE TABLES

# Public-RT
resource "aws_route_table" "final-project-1-public-RT" {
  vpc_id = aws_vpc.final-project-1.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.final-project-1-IGW.id
  }

  tags = {
    Name = "final-project-1-public-RT"
  }
}
# SUBNET - ROUTE TABLE ASSOCIATION -PUBLIC
resource "aws_route_table_association" "final-project-1-public-asc" {
  subnet_id      = aws_subnet.final-project-1-public-subnet.id
  route_table_id = aws_route_table.final-project-1-public-RT.id
}
# Security Groups

# Ansible-Master-Security Group
resource "aws_security_group" "final-project-1-Ansible-Master-Security-Group" {
  name        = "final-project-1-Ansible-Master-Security-Group"
  description = "Allow SSH-HTTP inbound traffic"
  vpc_id      = aws_vpc.final-project-1.id

  ingress {
    description = "SSH from WWW"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from WWW"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "final-project-1-Ansible-Master-Security Group"
  }
}

# 1. Create IAM Role
resource "aws_iam_role" "final-project-1-ec2-role" {
  name = "final-project-1-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 2. Attach AdministratorAccess Policy to Role
resource "aws_iam_role_policy_attachment" "final-project-1-ec2-role-admin-access" {
  role       = aws_iam_role.final-project-1-ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# 3. Create IAM Instance Profile
resource "aws_iam_instance_profile" "final-project-1-ec2-instance-profile" {
  name = "final-project-1-ec2-instance-profile"
  role = aws_iam_role.final-project-1-ec2-role.name
}

# 4. Attach IAM Instance Profile to EC2 instance
resource "aws_instance" "final-project-1-Ansible-Master" {
  ami                    = "ami-0d0f28110d16ee7d6"
  instance_type          = "t2.medium"
  key_name               = "devops_1"
  vpc_security_group_ids = [aws_security_group.final-project-1-Ansible-Master-Security-Group.id]
  private_ip             = "10.0.1.10"
  subnet_id              = aws_subnet.final-project-1-public-subnet.id
  iam_instance_profile   = aws_iam_instance_profile.final-project-1-ec2-instance-profile.name

  metadata_options {
    http_tokens = "optional"
  }

  user_data = <<-EOF
                #!/bin/bash
                yum -y update
                yum -y install git
                yum -y install ansible
            EOF

  tags = {
    Name = "final-project-1 Ansible Master"
  }
}

# 5. Create S3 Bucket for K8s Store
resource "aws_s3_bucket" "final-project-1-k8s-store" {
  bucket = "final-project-1-k8s-store"
  tags = {
    Name        = "final-project-1-k8s-store"
    Environment = "Production"
  }
}

resource "aws_route53_zone" "final_project_1_k8s_cluster_local" {
  name = "final-project-1-k8s-cluster.local"

  vpc {
    vpc_id = aws_vpc.final-project-1.id
  }

  comment = "Private hosted zone for Kubernetes cluster"

  tags = {
    Name        = "final-project-1-k8s-cluster.local"
    Environment = "dev"
  }
}
