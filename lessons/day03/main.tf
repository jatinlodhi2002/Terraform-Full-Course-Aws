module "s3_bucket" {
  source = "./s3"

  bucket_name = var.bucket_name
  tag_name    = var.tag_name
  environment = var.environment
}
