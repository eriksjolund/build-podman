#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error: Wrong number of arguments"
    exit 1
fi

config="$1"

go_version="$(cat checkout_build_podman/config/${config}.json | jq -r .go_version)"
installprefix="$(cat checkout_build_podman/config/${config}.json | jq -r .installprefix)"

podman run \
  --rm \
  -v "$GITHUB_WORKSPACE/output:${installprefix}" \
  -v "$GITHUB_WORKSPACE/checkout_build_podman:/checkout_build_podman" \
  -v /opt/hostedtoolcache/go:/opt/hostedtoolcache/go \
  -v "$GITHUB_WORKSPACE/gopath:/gopath" \
  -e "GOROOT=/opt/hostedtoolcache/go/${go_version}/x64" \
  localhost/build-podman:${config} \
    bash /checkout_build_podman/build_podman.bash "${installprefix}"
