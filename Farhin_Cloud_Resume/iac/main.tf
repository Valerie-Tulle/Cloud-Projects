
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

 resource "aws_cloudfront_origin_access_identity" "oai" {
    comment = "OAI for s3 bucket"
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

 resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name = aws_s3_bucket.farhin_website_bucket.bucket_regional_domain_name
        origin_id = "s3-${aws_s3_bucket.farhin_website_bucket.id}"
        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
        }
    }

    enabled = true
    is_ipv6_enabled = true
    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "s3-${aws_s3_bucket.farhin_website_bucket.id}"

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400

    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true 
    }

    tags = {
    Name = "Billing-Monitor"
    Value = "bill_costs"
  } 
 }

