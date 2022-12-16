#!/usr/bin/env bash

WORKDIR="./manylinux/" MANYLINUX_BUILD_FRONTEND="echo" COMMIT_SHA=latest POLICY="manylinux2014" PLATFORM="x86_64" BASEIMAGE_OVERRIDE="nvidia/cuda:11.8.0-devel-centos7" ./manylinux/build.sh
WORKDIR="./manylinux/" MANYLINUX_BUILD_FRONTEND="echo" COMMIT_SHA=latest POLICY="manylinux2014" PLATFORM="x86_64" BASEIMAGE_OVERRIDE="nvidia/cuda:12.0.0-devel-centos7" ./manylinux/build.sh
WORKDIR="./manylinux/" MANYLINUX_BUILD_FRONTEND="echo" COMMIT_SHA=latest POLICY="manylinux_2_31" PLATFORM="aarch64" BASEIMAGE_OVERRIDE="nvidia/cuda:11.8.0-devel-ubuntu20.04" ./manylinux/build.sh
WORKDIR="./manylinux/" MANYLINUX_BUILD_FRONTEND="echo" COMMIT_SHA=latest POLICY="manylinux_2_31" PLATFORM="aarch64" BASEIMAGE_OVERRIDE="nvidia/cuda:12.0.0-devel-ubuntu20.04" ./manylinux/build.sh
