# main.tf

provider "aws" {
  region = "us-west-2"
  # Use environment variables or an AWS credentials profile for secure access
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "private"  # Fix: Set access control to private

  versioning {
    enabled = true  # Fix: Enable versioning to prevent accidental data loss
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # Fix: Ensure server-side encryption is enabled
      }
    }
  }

  tags = {
    Name        = "ExampleBucket"
    Environment = "Production"
  }
}

resource "aws_security_group" "secure_sg" {
  name_prefix = "secure-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]  # Fix: Restrict access to a specific IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-security-group"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = var.db_username  # Fix: Use a variable for sensitive data
  password             = var.db_password  # Fix: Use a variable for sensitive data
  publicly_accessible  = false            # Fix: Make the database private
  skip_final_snapshot  = false            # Fix: Ensure a final snapshot is taken on deletion

  tags = {
    Name = "ExampleDatabase"
  }
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
}

output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}
