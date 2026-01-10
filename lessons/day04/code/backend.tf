# backend configuration
terraform {
  backend "s3" {
    bucket       = "terraform-state-1768056531"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}