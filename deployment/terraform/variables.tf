variable "api_services" {
  default = [
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
  ]
  description = "List of API services to enable"
  type        = list(string)
}

variable "environments" {
  default = {
    dev  = "dev"
    prod = "master"
  }
  description = "Names and branches of deployment environments"
  type        = map(string)
}

variable "project" {
  description = "GCP project managed by the default/primary provider"
  type        = string
}

variable "region" {
  description = "Region used by the default/primary provider"
  type        = string
}

variable "repo_name" {
  description = "Name of the artifact registry repository in which to store the container image"
  type        = string
}
