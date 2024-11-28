provider "aws" {
  region = "us-east-1"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
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
    cidr_blocks = ["192.168.1.0/24"] # Allow restricted egress
  }

  tags = {
    Name = "secure-security-group"
  }
}

resource "aws_kms_key" "db_kms" {
  description             = "KMS key for encrypting RDS data"
  deletion_window_in_days = 30

  tags = {
    Name = "DatabaseKMSKey"
  }
}

resource "aws_kms_key_rotation" "db_kms_rotation" {
  key_id = aws_kms_key.db_kms.id
}

resource "aws_db_instance" "example" {
  allocated_storage             = 20
  engine                        = "mysql"
  engine_version                = "5.7"
  instance_class                = "db.t2.micro"
  name                          = "exampledb"
  username                      = var.db_username
  password                      = var.db_password
  publicly_accessible           = false
  skip_final_snapshot           = false
  multi_az                      = true
  deletion_protection           = true
  auto_minor_version_upgrade    = true
  performance_insights_enabled  = true
  performance_insights_kms_key_id = aws_kms_key.db_kms.arn
  monitoring_interval           = 60
  storage_encrypted             = true
  kms_key_id                    = aws_kms_key.db_kms.arn
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery", "audit"]
  iam_database_authentication_enabled = true

  tags = {
    Name = "ExampleDatabase"
  }
}
