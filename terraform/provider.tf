provider "google" {
  # Configuration options
  project = var.project
  region = var.region
  zone = var.zone
}


terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.3.0"
    }
  }

  backend "gcs" {
    bucket = "GCS_NAME"
    prefix = "devops"
  }
}
