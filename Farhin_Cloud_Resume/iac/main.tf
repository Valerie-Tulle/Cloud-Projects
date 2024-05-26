
terraform {
    backend "s3" {
      bucket = "farhin-tf-state-bucket" 
      key = "terraform/state" #path to state file within the bucket
      region = "us-east-1"
      dynamodb_table = "farhin-tf-locks"
      encrypt = true
          }
}

provider "aws" {
    region = var.region
}


resource "aws_s3_bucket" "farhin_website_bucket" {
    bucket = var.bucket_name 
    acl = "private"
    website {
        index_document  = "index.html"
    } 
     tags = {
    Name = "Billing-Monitor"
    Value = "bill_costs"
  } 
 } 
 
 resource "aws_s3_bucket_policy" "website_bucket_policy" {
 bucket = aws_s3_bucket.farhin_website_bucket.id
 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "s3:GetObject"
            Effect = "Allow"
            Resource = "${aws_s3_bucket.farhin_website_bucket.arn}/*"
            Principal = "*"
        }
    ]
 })
 }

