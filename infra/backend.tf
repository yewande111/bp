# Terraform Backend Configuration
# This file defines the S3 backend for storing Terraform state

terraform {
  backend "s3" {
    bucket         = "bp-terraform-state-431774613177"
    region         = "eu-west-1"
    dynamodb_table = "bp-terraform-locks"
    encrypt        = true
    
    # The key will be specified at runtime using -backend-config
    # For staging: -backend-config="key=bp-calculator/staging/terraform.tfstate"
    # For production: -backend-config="key=bp-calculator/production/terraform.tfstate"
  }
}
