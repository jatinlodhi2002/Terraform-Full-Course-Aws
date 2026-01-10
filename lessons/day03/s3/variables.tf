variable "bucket_name" {
    type = string
    description = "The name of the S3 bucket"
    default = "s3-bucket-learn-tf-10-01-2026"
  
}

variable "tag_name" {
    type = string
    description = "The name tag for the S3 bucket"
    default = "My bucket"   

}

variable "environment" {
    type = string
    description = "The environment tag for the S3 bucket"
    default = "Dev"   
}