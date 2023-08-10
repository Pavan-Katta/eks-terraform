terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}
provider "aws" {
  region     = "${var.location}"
  
}

resource "aws_s3_bucket" "eks-test-backend" {
  bucket = "eks-test-backend"
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.eks-test-backend.id
  versioning_configuration {
    status = "Enabled"
    }
}
  

 resource "aws_dynamodb_table" "state_locking" {
  hash_key = "LockID"
  billing_mode     = "PAY_PER_REQUEST"
  name     = "eks_cluster_table"
  attribute {
    name = "LockID"
    type = "S"
  }
  
}
  
terraform {
  backend "s3" {
    bucket = "eks-test-backend"
    key    = "backend/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "eks_cluster_table"
  }
}
resource "aws_vpc" "vp1" {
  cidr_block       = "${var.vpc_cidr_block}"
  instance_tenancy = "default"
}

resource "aws_subnet" "public-1" {
 vpc_id                  = aws_vpc.vp1.id
 cidr_block              = "${var.subnet1_cidr_block}"
 availability_zone       = "eu-west-2a"
 map_public_ip_on_launch = true
 
}

resource "aws_subnet" "public-2" {
 vpc_id                  = aws_vpc.vp1.id
 cidr_block              = "${var.subnet2_cidr_block}"
 availability_zone       = "eu-west-2b"
 map_public_ip_on_launch = true
 
}
resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.vp1.id
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vp1.id
  route {
    cidr_block = "${var.route_cidr_block}"
    gateway_id = aws_internet_gateway.igw.id
 }
}

resource "aws_route_table_association" "a-1" {
 subnet_id = aws_subnet.public-1.id
 route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "a-2" {
 subnet_id = aws_subnet.public-2.id
 route_table_id = aws_route_table.rt1.id
}

resource "aws_security_group" "eks_sg" {
  name        = "test_eks_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vp1.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "${var.sg_protocol}"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}
