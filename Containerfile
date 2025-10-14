# While the app requirements do not specify a version of Python, the pinned
# werkzeug dependency makes a call to ast.Str, but that was deprecated in
# 3.8 and has since been removed:
# https://docs.python.org/3/deprecations/pending-removal-in-3.14.html
# As of writing this, Python 3.14 was released one week ago, so the application
# fails without pinning a specific version.
FROM docker.io/python:3.13-trixie AS build
ARG WORKDIR=/workdir
WORKDIR $WORKDIR

# Because `build.sh` hardcodes the virtualenv path to be in the same directory
# as the build context, we can't simply mount in the source code, since that
# would require writing to the mounted directory (not good practice, reduces
# portability).
COPY ./ $WORKDIR
RUN pip install virtualenv --root-user-action ignore
RUN bash build.sh

# Prevent the process from running as pid 1. Users can work around this with
# podman with the `--init` flag, but it gets more annoying when you try to run
# the container in kubernetes. For more details on what this is and how it
# works, see: https://github.com/krallin/tini/issues/8#issuecomment-146135930
RUN apt-get update && apt-get install -y tini

# For a trivial Python package a multi-stage build is a little silly, but this
# pattern is critical for most other build pipelines, including Python if you've
# got any dependencies built in other languages (Numpy is big!). Even for
# a small app like, this, if the software were properly packaged
# (pyproject.toml, etc.), we could simply copy over the virtual environment and
# not have to ship the source code, build scripts, etc. in a production app.
FROM docker.io/python:3.13-slim-trixie
ARG WORKDIR=/workdir
WORKDIR $WORKDIR

COPY --from=build $WORKDIR $WORKDIR
COPY --from=build /usr/bin/tini /usr/bin/tini

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "run.sh"]
