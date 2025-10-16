terraform {
  required_version = "1.13.4"

  backend "gcs" {
    # Bucket created manually. Normally I'd have a separate, dedicated repo for
    # automation related to shared Terraform infrastructure accross the
    # team/org. Setting that up isn't necessary for a brief technology
    # demonstration.
    bucket = "lihu-terraform-backend"
    prefix = "helloapp"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "7.7.0"
    }
  }
}
