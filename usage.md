# Usage

This repository defines a trivial web application that returns
`"<p>Hello, World!</p>"` in response to a GET and does nothing else.

## Using the container image

To build the image, from the root of the directory, run:

```bash
podman build . -t devops-task
```

After that, start the webserver with:

```bash
podman container run \
  --rm \
  --detach \
  --publish 8080:8080 \
  devops-task:latest
```

Run unit tests locally by calling the `test.sh` script:

```bash
podman container run --rm devops-task:latest bash test.sh
```

## Deploying the app with kubernetes

For the purpose of this assignment the example cluster is locally hosted with
minikube. The KRM files are mostly portable, but the container image would need
to be uploaded to a registry and updated in the deployment file for this
infrastructure to work with most cloud providers.

### Setting up minikube with rootless podman

A few extra steps are necessary to get minikube running with a rootless podman
driver. These can be skipped if you're using a different platform or
backend. First, run these two commands to configure minikube:

```bash
minikube config set rootless true
minikube start --driver=podman --container-runtime=containerd
```

Next, since the cluster is entirely local, you will need to manually load the
custom image from [the previous step.](#using-the-container-image) After having
built the image, run:

```bash
podman save localhost/devops-task:latest -o devops-task.tar
minikube image load devops-task.tar
```

### Running and accessing the web server

Set up the deployment and server with:

```bash
kubectl apply -k deployment/prod
```

An ingress is not provided, as described in the assignment prompt. Instead, use
`kubectl` to port forward and expose the app:

```bash
kubectl port-forward services/prod-helloapp-service 8080:8080
```

Now the application will be locally accessible:

```bash
$ curl localhost:8080
<p>Hello, World!</p>
```

To tear down the infrastructure:

```bash
kubectl delete -k deployment/prod
```

## Accessing the deployed application on GCP

A CI/CD pipeline is set up so that any push to the `dev` or `master` branch is
immediately tested and deployed to the appropriate environment. These are hosted
on my personal Free-tier GCP account, so they have very few resources allocated
to them and are heavily throttled, but for an application that barely does
anything it should be more than sufficient. Initial access will be slow because
I don't keep any pods running when they're not in use to reduce cost.

The development instance, synced to the `dev` branch, is at
https://dev-helloapp-1093269280327.us-east1.run.app

The production instance, synced to the `master` branch, is at
https://prod-helloapp-1093269280327.us-east1.run.app

They don't have nice names, because Cloud DNS isn't included in GCP's free tier.
