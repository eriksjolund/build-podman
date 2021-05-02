#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error: Wrong number of arguments"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "Error: $1 is not a directory"
    exit 1
fi

installprefix="$1"

export PATH=$GOROOT/bin:$PATH
export LD_LIBRARY_PATH=$GOROOT/lib:$LD_LIBRARY_PATH
export GOPATH=/gopath

PATH=/go/bin:$PATH && cd $GOPATH/src/github.com/containers/conmon && \
    make "PREFIX=$installprefix" && \
    make "PREFIX=$installprefix" podman && \
    make "PREFIX=$installprefix" install && \
    cd $GOPATH/src/github.com/containers/podman && \
    make BUILDTAGS="seccomp exclude_graphdriver_btrfs systemd" && \
    make "PREFIX=$installprefix" install && \
    cd $GOPATH/src/github.com/containernetworking/plugins && \
    ./build_linux.sh && \
    mkdir -p "$installprefix/libexec/cni" && \
    cp -fR bin/* "$installprefix/libexec/cni"
