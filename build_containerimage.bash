#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error: Wrong number of arguments"
    exit 1
fi

config="$1"

# set array buildargs
IFS=$'\t' read -r -a buildargs < <(cat "checkout_build_podman/config/${config}.json" | jq -r  '[.container.build_args | to_entries[] | "--build-arg=\(.key)=\(.value)"] | @tsv');

dockerfile="$(cat checkout_build_podman/config/${config}.json | jq -r .container.dockerfile)"

podman --log-level=debug build "${buildargs[@]}" -t "build-podman:$config" -f "checkout_build_podman/container/$dockerfile" checkout_build_podman/
