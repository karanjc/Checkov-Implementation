provider "aws" {
  region = "us-east-1"
}

# Security Group Resource
resource "aws_security_group" "secure_sg" {
  name_prefix = "secure-sg-"
  description = "Security group for restricting access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"] # Restricting SSH access to a known IP range
    description = "Allow SSH access from specific IP range"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["192.168.1.0/24"] # Restricting egress to specific CIDR
    description = "Allow all egress within the specified CIDR range"
  }

  tags = {
    Name = "secure-security-group"
  }
}

# RDS KMS Key
resource "aws_kms_key" "db_kms" {
  description             = "KMS key for encrypting RDS data"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name = "DatabaseKMSKey"
  }
}

# RDS Instance
resource "aws_db_instance" "example" {
  allocated_storage          = 20
  engine                     = "mysql"
  engine_version             = "5.7"
  instance_class             = "db.t2.micro"
  name                       = "exampledb"
  username                   = var.db_username
  password                   = var.db_password
  publicly_accessible        = false
  skip_final_snapshot        = false
  multi_az                   = true
  deletion_protection        = true
  auto_minor_version_upgrade = true
  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.db_kms.arn
  monitoring_interval        = 60
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.db_kms.arn
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery", "audit"]

  # Enable IAM database authentication
  iam_database_authentication_enabled = true

  tags = {
    Name = "ExampleDatabase"
  }
}

# Variable definitions
variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}
