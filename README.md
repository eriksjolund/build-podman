# build-podman

Building [Podman](https://github.com/containers/podman) with Github actions.

This project is trying to help out in the situation where you want to be able to run 
`podman` on a CentOS compute cluster where you don't have root permission but only normal user permission. In other words
the normal installation procedure to install RPM packages (`dnf install podman` or `yum install podman`) is not possible.

The GitHub actions workflow [.github/workflows/build.yml](.github/workflows/build.yml) contains a matrix

```
    strategy:
      matrix:
        config: [ centos7, centos8 ]
```

that specifies the names of the build configurations to build. The build configurations are JSON files located under _config/_, for instance _config/centos8.json_

```
{
    "go_version": "1.15.3",
    "gitrepos": {
        "podman": {
            "ref": "ad1aaba8df96cb25e12fe28ec96f3c131e572e3e",
            "repository": "containers/podman"
        },
        "conmon": {
            "ref": "v2.0.27",
            "repository": "containers/conmon"
        },
        "CNI-plugins": {
            "ref": "v0.9.1",
            "repository": "containernetworking/plugins"
        }
    },
    "container": {
        "dockerfile": "Dockerfile.centos",
        "build_args": {
            "CENTOS_VERSION": "8.3.2011"
        }
    },
    "download": {
        "crun": "0.19.1",
        "slirp4netns": "v1.1.9",
        "fuse-overlayfs": "v1.5.0"
    },
    "installprefix": "/home/erik.sjolund/podman"
}
```

The executables

* crun
* slirp4netns
* fuse-overlayfs

are not built but instead downloaded and added to the tar archive together with the Podman build results.
The tar archive is then uploaded as an artifact to GitHub.


#### TODO and caveats

* There is an unnecessary warning _WARN[0000] Found default OCIruntime /some/path/bin/crun path which is missing from [engine.runtimes] in containers.conf_ (see https://github.com/containers/podman/issues/9389) that can be ignored. The bug has been fixed in https://github.com/containers/common/releases/tag/v0.37.0 but no Podman release has yet included this common version.
* After uncompressing the archive, there might be a need to set file SELinux security contexts with `chcon -R ` (TODO: investigate this. It seems to be a problem only when untarring outside of the home directory)
* Investigate if _installprefix_ matters at all. (Does it have to match the path where the tar archive is untarred?)

## Install into home directory

A sketch:

```
cd ~
unzip ~/Downloads/build-podman_ebb721f1868e408e1f82ef0edf182f8bf4641969__centos8__ad1aaba8df96cb25e12fe28ec96f3c131e572e3e__v2.0.27__v0.9.1__1.15.3__0.19.1__v1.1.9__v1.5.0.tar.zip
tar xf build-podman_ebb721f1868e408e1f82ef0edf182f8bf4641969__centos8__ad1aaba8df96cb25e12fe28ec96f3c131e572e3e__v2.0.27__v0.9.1__1.15.3__0.19.1__v1.1.9__v1.5.0.tar
ln -s build-podman_ebb721f1868e408e1f82ef0edf182f8bf4641969__centos8__ad1aaba8df96cb25e12fe28ec96f3c131e572e3e__v2.0.27__v0.9.1__1.15.3__0.19.1__v1.1.9__v1.5.0 podman
```

Create the configuration files _~/.config/containers/containers.conf_
and _~/.config/containers/storage.conf_. (TODO: provide examples of how they could look like)

## Usage

Run podman

```
podman run --rm -ti docker.io/library/alpine
```

## Adjusting user systemd services

If you have generated systemd services with the command `podman generate systemd --new` and installed them under _~/.config/systemd/user_ , you need to replace occurences of `/usr/bin/podman` with `%h/podman/bin/podman`
in your files  _~/.config/systemd/user/*.service_. 

Also adjust the environment variables for the user systemd service

```
mkdir ~/.config
echo ~/podman/bin:~/bin:$PATH > ~/.config/EnvironmentFile.systemd_podman
```

(the filename _EnvironmentFile.systemd_podman_ was arbitrarily chosen)

Then add the line

```
EnvironmentFile=%S/EnvironmentFile.systemd_podman
```
in your podman user systemd service files.

For instance the lines

```
ExecStartPre=/bin/rm -f %t/%n-pid %t/%n-cid
ExecStart=/usr/bin/podman run --conmon-pidfile %t/%n-pid --cidfile %t/%n-cid --cgroups=no-conmon -d -dit alpine
ExecStop=/usr/bin/podman stop --ignore --cidfile %t/%n-cid -t 10
ExecStopPost=/usr/bin/podman rm --ignore -f --cidfile %t/%n-cid
```
should be replaced with

```
EnvironmentFile=%S/EnvironmentFile.systemd_podman
ExecStartPre=/bin/rm -f %t/%n-pid %t/%n-cid
ExecStart=%h/podman/bin/podman run --conmon-pidfile %t/%n-pid --cidfile %t/%n-cid --cgroups=no-conmon -d -dit alpine
ExecStop=%h/podman/bin/podman stop --ignore --cidfile %t/%n-cid -t 10
ExecStopPost=%h/podman/bin/podman rm --ignore -f --cidfile %t/%n-cid
```
