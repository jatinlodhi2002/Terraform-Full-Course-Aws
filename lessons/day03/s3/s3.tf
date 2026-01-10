
# Create a S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name  #"s3_bucket_learn_tf_10_01_2026"

  tags = {
    Name        = var.tag_name  #"My bucket"
    Environment = var.environment #"Dev"
  }
}