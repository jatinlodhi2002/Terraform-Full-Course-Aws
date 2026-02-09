terraform {
  backend "s3" {
    bucket  = "terraform-state-1768056531"
    key     = "day15-project/terraform.tfstate"
    region  = "us-east-1"
    profile = "learn-tf"
  }
}
