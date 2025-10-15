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
