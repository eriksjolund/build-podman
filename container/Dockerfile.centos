ARG CENTOS_VERSION=8.3.2011
FROM docker.io/library/centos:${CENTOS_VERSION}
ARG CENTOS_VERSION
# Maybe add 
# libselinux-devel
# glibc-static
# device-mapper-devel
SHELL ["/bin/bash", "-c"]
RUN set -o nounset && yum -y install \
      autoconf \
      automake \
      gcc \
      git \
      glib2-devel \
      glibc-devel \
      iptables \
      libgpg-error-devel \
      libseccomp-devel \
      libtool \
      make \
      pkgconf-pkg-config \
      pkgconfig \
      systemd-devel && \
    major_version=$(cut -d '.' -f 1 <<< ${CENTOS_VERSION} ) && \
    if [ -n "$major_version" ]; then \
      if [ "$major_version" == "8" ]; then \
        repo=/etc/yum.repos.d/CentOS-PowerTools.repo && \
        minor_version=$(cut -d '.' -f 2 <<< ${CENTOS_VERSION} ) && \
        if [ -n "$minor_version" ]; then \
          if [ $minor_version -ge 3 ]; then \
            repo=/etc/yum.repos.d/CentOS-Linux-PowerTools.repo; \
          fi; \
        fi; \
        sed -i s/enabled=0/enabled=1/ $repo ; \
      fi; \
    fi && \
    yum install -y \
      device-mapper \
      device-mapper-devel \
      device-mapper-libs \
      gpgme-devel \
      libassuan-devel && \
    yum clean all
