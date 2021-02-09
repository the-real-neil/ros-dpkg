# ros-dpkg/Dockerfile

ARG DOCKER_TAG="latest"
FROM ros:${DOCKER_TAG}
ENV ROSDISTRO_INDEX_URL="file:///etc/ros/index-v4.yaml"
ARG VCS_URL
ARG VCS_REF
ARG SOURCE_DATE_EPOCH
ARG SOURCE_DATE
ARG BUILD_DATE
LABEL \
    org.label-schema.schema-version="1.0" \
    org.label-schema.vcs-url="${VCS_URL}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.source-date-epoch="${SOURCE_DATE_EPOCH}" \
    org.label-schema.source-date="${SOURCE_DATE}" \
    org.label-schema.build-date="${BUILD_DATE}"
ARG BUILD_CODE="default-build-code"
WORKDIR /tmp/${BUILD_CODE}
RUN set -euvx \
  && echo \
  && echo "make this container behave like a chroot" \
  && dpkg-divert --local --rename /usr/bin/ischroot \
  && ln -vsf /bin/true /usr/bin/ischroot \
  && echo \
  && echo "install packages for building" \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install \
       apt-cudf \
       clang-9 \
       curl \
       devscripts \
       dh-systemd \
       dpkg-dev \
       equivs \
       fakeroot \
       faketime \
       git \
       git-buildpackage \
       libarchive-tools \
       libdistro-info-perl \
       libfile-fcntllock-perl \
       liblz4-tool \
       libomp-dev \
       libparse-debcontrol-perl \
       lintian \
       linux-image-generic \
       symlinks \
       udev \
       xz-utils \
  && echo \
  && echo "update-alternatives clang-9" \
  && update-alternatives --install /usr/bin/c++ c++ "$(command -v clang++-9)" 1000 \
  && update-alternatives --install /usr/bin/cc  cc  "$(command -v clang-9)"   1000 \
  && echo \
  && echo "freeze rosdistro" \
  && curl -fsSL https://github.com/ros/rosdistro/archive/master.tar.gz \
       | tar -C /etc/ros --strip-components 1 -xzf- \
  && sed -i s,https://raw.githubusercontent.com/ros/rosdistro/master,file:///etc/ros,g \
       /etc/ros/rosdep/sources.list.d/20-default.list \
  && echo \
  && echo "done"
