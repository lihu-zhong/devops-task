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
