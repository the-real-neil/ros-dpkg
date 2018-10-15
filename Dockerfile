# ros-debbah/Dockerfile

ARG SOURCE_BRANCH="latest"
FROM ros:${SOURCE_BRANCH}
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
ADD configure-apt .
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
  && echo "install tools for pcakage building" \
  && apt-get -y --no-install-recommends install \
       devscripts \
       dpkg-dev \
       equivs \
       fakeroot \
       git \
       git-buildpackage \
       libdistro-info-perl \
       libfile-fcntllock-perl \
       libparse-debcontrol-perl \
       linux-image-$(uname -r) \
       udev \
       xz-utils \
  && echo \
  && echo "re-installing linux image" \
  && apt-get install --reinstall linux-image-$(uname -r) \
  && echo \
  && echo "done"
