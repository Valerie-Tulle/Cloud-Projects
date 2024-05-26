# backend-setup.tf  to configure terraform for s3 bucket & DnamoDB table for state management
#provider "aws" {
 #   region = "us-east-1"
#}

resource "aws_s3_bucket" "farhin_tf_state" {
    bucket = "farhin-tf-state-bucket" 
    acl = "private"

    versioning {
        enabled = true
    }

    tags = {
    Name = "Billing-Monitor"
    Value = "bill_costs"
  }

    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}

resource "aws_dynamodb_table" "farhin_tf_locks" {
    name = "farhin-tf-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type ="S"
    }

    tags = {
    Name = "Billing-Monitor"
    Value = "bill_costs"
  }
  
}