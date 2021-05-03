#!/bin/bash

# Podman issue 9389 has already been fixed in the Podman master branch
# (See https://github.com/containers/podman/issues/9389)
# Remove this workaround later

file=gopath/src/github.com/containers/podman/vendor/github.com/containers/common/pkg/config/config.go

if [ ! -w $file ]; then
  echo Trying to fix Podman issue 9389
  echo Source file is missing: $file
  exit 1
fi

sed -i 's#logrus.Warningf("Found default OCIruntime %s path which is missing from \[engine.runtimes\] in containers.conf", path)#logrus.Debugf("Found default OCI runtime %s path via PATH environment variable", path)#g' $file
