provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "<<terraform_state_bucket_name>>"
    prefix = "terraform/state"
  }
}