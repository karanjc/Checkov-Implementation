provider "aws" {
  region     = "us-west-2"
  access_key = "AKIAIOSFODNN7EXAMPLE"       # Vulnerability: Hardcoded AWS Access Key
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" # Vulnerability: Hardcoded AWS Secret Key
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "public-read"  # Vulnerability: Public read access

  versioning {
    enabled = false  # Vulnerability: Versioning not enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "ExampleBucket"
    Environment = "Production"
  }
}

resource "aws_security_group" "insecure_sg" {
  name_prefix = "insecure-sg-"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Vulnerability: Open to the world
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "insecure-security-group"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "exampledb"
  username             = "admin"
  password             = "hardcoded-password" # Vulnerability: Hardcoded database password
  publicly_accessible  = true                 # Vulnerability: Publicly accessible database
  skip_final_snapshot  = true                 # Vulnerability: Final snapshot skipped

  tags = {
    Name = "ExampleDatabase"
  }
}

#25
