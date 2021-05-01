#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Error: Wrong number of parameters"
    exit 1
fi

config="$1"

buildargs=($(cat checkout_build_podman/config/${config}.json | jq -r  '[.container["build-args"] | to_entries[] | @sh  "--build-arg=\(.key)=\(.value)"] | join(" ") '))

dockerfile="$(cat checkout_build_podman/config/${config}.json | jq -r .container.dockerfile )"
echo dockerfile=$dockerfile
echo podman build ${buildargs[@]} -t "build-podman:$config" -f "checkout_build_podman/container/$dockerfile" checkout_build_podman/

podman --log-level=debug build ${buildargs[@]} -t "build-podman:$config" -f "checkout_build_podman/container/$dockerfile" checkout_build_podman/
