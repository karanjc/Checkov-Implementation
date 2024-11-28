provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "private"

  versioning {
    enabled = true
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

resource "aws_security_group" "secure_sg" {
  name_prefix = "secure-sg-"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]  # Fix: Restrict egress traffic instead of allowing all
  }

  tags = {
    Name = "secure-security-group"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = "exampledb"
  username               = var.db_username
  password               = var.db_password
  publicly_accessible    = false
  skip_final_snapshot    = false
  multi_az               = true                          # Fix: Enable Multi-AZ deployment for high availability
  deletion_protection    = true                          # Fix: Enable deletion protection
  auto_minor_version_upgrade = true                     # Fix: Enable automatic minor version upgrades
  performance_insights_enabled = true                   # Fix: Enable performance insights
  performance_insights_kms_key_id = aws_kms_key.db_kms.arn  # Fix: Use KMS encryption for performance insights
  monitoring_interval    = 60                            # Fix: Enable enhanced monitoring

  storage_encrypted      = true                          # Fix: Encrypt RDS storage
  kms_key_id             = aws_kms_key.db_kms.arn        # Fix: Use custom KMS key for encryption

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery", "audit"] # Fix: Enable CloudWatch logs for RDS

  tags = {
    Name = "ExampleDatabase"
  }
}

resource "aws_kms_key" "db_kms" {
  description             = "KMS key for encrypting RDS data"
  deletion_window_in_days = 30

  tags = {
    Name = "DatabaseKMSKey"
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
