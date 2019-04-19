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
COPY ./scrippies/configure-apt .
COPY ./scrippies/configure-rosdep .
COPY ./scrippies/inject-librscalibrationapi .
COPY ./scrippies/strip-maint .
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
       curl \
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
       python-pip \
       udev \
       xz-utils \
  && echo \
  && echo "install catkin-tools (because https://github.com/catkin/catkin_tools/pull/511)" \
  && curl -fsSLo catkin_tools-master.tar.gz https://github.com/catkin/catkin_tools/archive/master.tar.gz \
  && tar -xf catkin_tools-master.tar.gz \
  && ( cd catkin_tools-master \
       && pip install -r requirements.txt --upgrade \
       && python setup.py install --record install_manifest.txt ) \
  && echo \
  && echo "check librscalibrationapi" \
  && apt-cache show librscalibrationapi \
  || ( ./inject-librscalibrationapi \
       && ./configure-rosdep "file:///var/packages/Packages" ) \
  && echo \
  && echo "configure rosdep realsense" \
  && ./configure-rosdep \
    "http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo/dists/$(lsb_release -sc)/main/binary-amd64/Packages" \
  && echo \
  && echo "install strip-maint" \
  && ./strip-maint -I "$(dirname "$(command -v switch_root)")" \
  && echo \
  && echo "done"
