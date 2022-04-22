provider "aws" {
  region = var.region
}

module "vpc_basic" {
  source        = "./vpc"
  name          = "web"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
}

resource "aws_instance" "web" {
  ami                         = var.ami[var.region]
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc_basic.public_subnet_id
  private_ip                  = var.instance_ips[count.index]
  user_data                   = file("files/web_bootstrap.sh")
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.web_host_sg.id,
  ]

  tags = {
    Name = "web-${format("%03d", count.index + 1)}"
  }

  count = length(var.instance_ips)
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = module.vpc_basic.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [module.vpc_basic.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state111"
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks111"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"  
  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state111"
    key            = "terraform.tfstate"
    region         = "us-east-1"    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks111"
    encrypt        = true
  }
}
