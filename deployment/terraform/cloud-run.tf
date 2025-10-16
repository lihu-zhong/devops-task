# There is an official cloud run module with more bells and whistles that makes
# some common associated tasks, like IAM and mounting storage, easier. None of
# those features are relevant for an app this simple, so I'm using the bare
# resource, but I would migrate over if the scope of this project increased.
resource "google_cloud_run_v2_service" "helloapp" {
  for_each = var.environments

  name                 = "${each.key}-helloapp"
  location             = var.region
  deletion_protection  = true
  invoker_iam_disabled = true

  # Keep things cheap for the assignment, but this would be higher for an
  # application under real load.
  scaling {
    max_instance_count = 1
  }

  template {
    # This is just for initialization -- it will be overridden by the cloud
    # build pipeline. Unfortunately, that means that terraform will clobber that
    # if I re-deploy the infrastructure, so I made the pipeline add a "latest"
    # tag to each repo which should alway correspond to what's live, at least in
    # this simplistic setup. This is not the most elegant solution, since
    # terraform will still indicate a change from "<sha>" to "latest", but it
    # should not affect uptime.
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project}/${var.repo_name}/devops-task/${each.key}-helloapp:latest"
      name  = "placeholder-1"
    }
    timeout = "30s"
  }
}
