provider "google" {
  project = var.project
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_storage_bucket" "terraform_state" {
  name          = "<CLIENT>2-tf-state-${terraform.workspace}"
  project       = var.project
  location      = var.region
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}

resource "google_redis_instance" "cache" {
  name               = "<CLIENT>2-cache-${terraform.workspace}"
  memory_size_gb     = 12
  redis_version      = "REDIS_6_X"
  authorized_network = module.network.network_name
}

terraform {
  backend "gcs" {
    bucket = "<CLIENT>2-tf-state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.64.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}
