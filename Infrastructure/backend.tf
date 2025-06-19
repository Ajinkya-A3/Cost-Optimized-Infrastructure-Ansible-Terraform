terraform {
  backend "s3" {
    bucket       = "my-terraform-lock-bucket-007"
    key          = "terraform.tfstate"
    region       = "ap-south-2"
    encrypt      = true
    use_lockfile = true
  }
}