# There is an option to only trigger if specific files in the repo are changed,
# which would be useful in cutting down needless when peripheral files are
# updated. However, the current package structure makes that clunky because the
# app-related files are not grouped in a way that makes capturing them with
# a single glob easy, so I'm leaving it off.
resource "google_cloudbuild_trigger" "merge" {
  for_each = var.environments

  description        = "Build and deploy to ${each.key}-helloapp on push to ${each.value} branch"
  name               = "${each.key}-on-push-devops-task-${var.region}"
  location           = var.region
  filename           = ".cloudbuild/deploy.yaml"
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  # This is the default service account. I'm keeping it here because this is the
  # only project on my free GCP trial account, but using the default service
  # account in any sort of real production setting is *very* bad security
  # practice.
  service_account = "projects/${var.project}/serviceAccounts/1093269280327-compute@developer.gserviceaccount.com"
  substitutions = {
    "_AR_HOSTNAME"   = "${var.region}-docker.pkg.dev"
    "_AR_PROJECT_ID" = var.project
    "_AR_REPOSITORY" = var.repo_name
    "_DEPLOY_REGION" = var.region
    "_PLATFORM"      = "managed"
    "_SERVICE_NAME"  = "${each.key}-helloapp"
  }
  tags = [
    "gcp-cloud-build-deploy-cloud-run",
    "gcp-cloud-build-deploy-cloud-run-managed",
    "${each.key}-helloapp",
  ]

  github {
    name  = "devops-task"
    owner = "lihu-zhong"
    push {
      branch       = "^${each.value}$"
      invert_regex = false
    }
  }
}

resource "google_cloudbuild_trigger" "pr" {
  for_each = var.environments

  description        = "Build and run unit tests when a PR is opened on ${each.value}"
  name               = "${each.key}-on-pr-devops-task-${var.region}"
  location           = var.region
  filename           = ".cloudbuild/test.yaml"
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  service_account    = "projects/${var.project}/serviceAccounts/1093269280327-compute@developer.gserviceaccount.com"
  tags = [
    "${each.key}-helloapp",
  ]

  github {
    name  = "devops-task"
    owner = "lihu-zhong"
    pull_request {
      branch          = "^${each.value}$"
      comment_control = "COMMENTS_ENABLED"
      invert_regex    = false
    }
  }
}
