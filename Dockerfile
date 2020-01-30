# ros-dpkg/Dockerfile

ARG DOCKER_TAG="latest"
FROM ros:${DOCKER_TAG}
ENV ROSDISTRO_INDEX_URL="file:///etc/ros/index-v4.yaml"
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
COPY ./scrippies/configure-apt .
RUN set -euvx \
  && echo \
  && echo "make this container behave like a chroot" \
  && dpkg-divert --local --rename /usr/bin/ischroot \
  && ln -vsf /bin/true /usr/bin/ischroot \
  && echo \
  && echo "install packages for configure-apt" \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install apt-transport-https gnupg \
  && echo \
  && echo "configure-apt" \
  && find /etc/apt/sources.list.d /var/lib/apt/lists -type f -print -delete \
  && ./configure-apt \
  && echo \
  && echo "install packages for building" \
  && apt-get -y update \
  && apt-get -y --no-install-recommends install \
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
  && curl -fsSL https://github.com/ros/rosdistro/archive/master.tar.gz \
       | tar -C /etc/ros --strip-components 1 -xzf- \
  && sed -i s,https://raw.githubusercontent.com/ros/rosdistro/master,file:///etc/ros,g \
       /etc/ros/rosdep/sources.list.d/20-default.list \
  && echo \
  && echo "done"
