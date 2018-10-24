ros-dpkg
==========

[![Docker Stars](https://img.shields.io/docker/stars/rubicks/ros-dpkg.svg)][hub]

[![Docker Pulls](https://img.shields.io/docker/pulls/rubicks/ros-dpkg.svg)][hub]

[![Docker Automated build](https://img.shields.io/docker/automated/rubicks/ros-dpkg.svg)][hub]

[![Docker Build Status](https://img.shields.io/docker/build/rubicks/ros-dpkg.svg)][hub]

Make ya debs fuh ROS, kid.

# What?

A git repository from which you can build docker images based on
`ros:(latest|kinetic|melodic)` --- with some Debian packaging tools installed.

# Why?

Because after you bloom stuff, you want to package stuff.

# How?

Every git branch becomes a docker tag of the same name. Except `master`. The
git branch `master` becomes the docker tag `latest`. Because docker.

[hub]:https://hub.docker.com/r/rubicks/ros-dpkg
