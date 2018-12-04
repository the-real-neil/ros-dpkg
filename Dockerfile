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
ADD ./scrippies/configure-apt .
ADD ./scrippies/configure-rosdep .
ADD ./scrippies/strip-maint .
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
       devscripts \
       dpkg-dev \
       equivs \
       fakeroot \
       git \
       git-buildpackage \
       libdistro-info-perl \
       libfile-fcntllock-perl \
       liblz4-tool \
       libparse-debcontrol-perl \
       linux-image-generic \
       udev \
       xz-utils \
  && echo \
  && echo "configure rosdep" \
  && ./configure-rosdep \
  && echo \
  && echo "install 'strip-maint'" \
  && ./strip-maint -I $(dirname $(command -v switch_root)) \
  && echo \
  && echo "done"
