#!/bin/bash

export PATH=$GOROOT/bin:$PATH
export LD_LIBRARY_PATH=$GOROOT/lib:$LD_LIBRARY_PATH
export GOPATH=/gopath

if [ $# -ne 1 ]; then
    echo "Error: Wrong number of arguments. 1 arguments are required."
    exit 1
fi

if [ ! -d $1 ]; then
    echo "Error: $1 is not a directory"
    exit 1
fi

PODMANINSTALLDIR=$1

PATH=/go/bin:$PATH && cd $GOPATH/src/github.com/containers/conmon && \
    make PREFIX=$PODMANINSTALLDIR && \
    make PREFIX=$PODMANINSTALLDIR podman && \
    make PREFIX=$PODMANINSTALLDIR install && \
    cd $GOPATH/src/github.com/containers/podman && \
    make BUILDTAGS="seccomp exclude_graphdriver_btrfs systemd" && \
    make PREFIX=$PODMANINSTALLDIR install && \
    cd $GOPATH/src/github.com/containernetworking/plugins && \
    ./build_linux.sh && \
    mkdir -p $PODMANINSTALLDIR/libexec/cni && \
    cp -fR bin/* $PODMANINSTALLDIR/libexec/cni
