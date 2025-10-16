resource "google_artifact_registry_repository" "devops-task" {
  location      = var.region
  repository_id = var.repo_name
  description   = "Cloud Run Source Deployments"
  format        = "DOCKER"
}
