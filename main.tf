provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "example" {
  vpc_id     = aws_vpc.example.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "example-subnet"
  }
}

# Create a security group
resource "aws_security_group" "example" {
  name_prefix = "example-"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-security-group"
  }
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0a887e401f7654935"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.example.id
  vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name = "example-instance"
  }
}

# Create an S3 bucket for a static website
resource "aws_s3_bucket" "static_website" {
  bucket = "tnbucket1337"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  source = "index.html"
  etag   = filemd5("index.html")
  acl    = "public-read"
  content_type = "text/html"
}


output "website_url" {
  value = "http://${aws_s3_bucket.static_website.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
}

data "aws_region" "current" {}


