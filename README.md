ros-dpkg
==========

![Pipeline](https://gitlab.com/realtime-robotics/ros-dpkg/badges/foxy/pipeline.svg)

An unholy union of ROS and Debian packaging tools.

# What?

A git repository that builds docker images based on
[https://hub.docker.com/_/ros](https://hub.docker.com/_/ros).

# Why?

Because after you bloom stuff, you want to package stuff. Or, maybe you have
[something else][bundling] you like to do.

# How?

Every git branch becomes a docker tag of the same name. Because docker. During
image building, we

* take the branch name to be the `${ROS_DISTRO}` (except `master` which becomes
  `latest`)

* work around a few ROS _peccadillos_

* install lots of Debian packaging tools

[bundling]:https://www.ros.org/news/2017/09/mike-purvis-clearpath-robotics-robust-deployment-with-ros-bundles.html
