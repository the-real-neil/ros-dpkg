# ros-dpkg/Dockerfile

ARG DOCKER_TAG="latest"
FROM ros:${DOCKER_TAG}
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
LABEL \
  org.label-schema.schema-version="1.0" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vcs-url="${VCS_URL}" \
  maintainer="Neil Roza <neil@rtr.ai>"
ARG BUILD_CODE="default-build-code"
WORKDIR /tmp/${BUILD_CODE}
ARG BUILD_CODE="default-build-code"
ENV \
    ROSDISTRO_INDEX_URL="file:///tmp/${BUILD_CODE}/rosdistro-master/index-v4.yaml" \
    ROSDEP_SOURCE_PATH="/tmp/${BUILD_CODE}/rosdistro-master/rosdep/sources.list.d"
COPY ./scrippies/configure-apt .
COPY ./scrippies/install-nodejs .
RUN set -euvx \
  && echo \
  && echo "make this container behave like a chroot" \
  && dpkg-divert --local --rename /usr/bin/ischroot \
  && ln -vsf /bin/true /usr/bin/ischroot \
  && echo \
  && echo "configure apt" \
  && find /etc/apt/sources.list.d /var/lib/apt/lists -type f -print -delete \
  && ./configure-apt \
  && echo \
  && echo "update apt" \
  && apt-get -y update \
  && echo \
  && echo "install tools for package building" \
  && apt-get -y --no-install-recommends install \
       apt-transport-https \
       bsdtar \
       clang-6.0 \
       curl \
       devscripts \
       dh-systemd \
       dpkg-dev \
       equivs \
       fakeroot \
       faketime \
       git \
       git-buildpackage \
       libdistro-info-perl \
       libfile-fcntllock-perl \
       liblz4-tool \
       libomp-dev \
       libparse-debcontrol-perl \
       linux-image-generic \
       python-catkin-tools \
       symlinks \
       udev \
       xz-utils \
  && echo \
  && echo "update-alternatives clang-6.0" \
  && update-alternatives --install /usr/bin/c++ c++ "$(command -v clang++-6.0)" 1000 \
  && update-alternatives --install /usr/bin/cc  cc  "$(command -v clang-6.0)"   1000 \
  && echo \
  && echo "freeze rosdistro" \
  && curl -fsSL https://github.com/ros/rosdistro/archive/master.tar.gz | tar -xzf- \
  && sed -i s,https://raw.githubusercontent.com/ros/rosdistro/master/,file:///${PWD}/rosdistro-master/,g \
         rosdistro-master/rosdep/sources.list.d/20-default.list \
  && rm -rf /etc/ros/rosdep \
  && echo \
  && echo "installing nodejs" \
  && ./install-nodejs \
  && echo \
  && echo "done"
