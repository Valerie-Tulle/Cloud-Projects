variable "bucket_name" {
    description = "The name of s3 bucket being used for website hosting"
    type = string
}

variable "region"{
    description = " The AWS region to create the resources in "
    type = string
    default = "us-east-1"
}


