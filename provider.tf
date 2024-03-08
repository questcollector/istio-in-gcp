provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "kiyoung-terraform-state"
    prefix = "terraform/state"
  }
}