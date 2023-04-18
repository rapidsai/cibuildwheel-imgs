#!/usr/bin/env bash

set -eou pipefail
set -x

curl --verbose https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --output ./dummy && echo $? && ls -latrh dummy

image_to_build="${BUILD_IMAGE:-""}"

if [[ "${image_to_build}" == "" ]]; then
        echo "Must specify BUILD_IMAGE" >&2
        exit 1
fi

# chop it up for informational purposes
img=$(echo "${image_to_build}" | tr "/:" "-")

cuda_variant=$(echo "${img}" | cut -d'-' -f3)

jetson="no"
if [[ "${cuda_variant}" == *"l4t"* ]]; then
        jetson="yes"
fi

img_type=$(echo "${img}" | cut -d'-' -f2)
cuda_type=$(echo "${img}" | cut -d'-' -f4)
cuda_ver=$(echo "${img}" | cut -d'-' -f5)
os=$(echo "${img}" | cut -d'-' -f6)
arch=$(echo "${img}" | cut -d'-' -f7)
real_arch=$(uname -m)

if [[ ("$arch" != "$real_arch") ]]; then
        echo "Image arch '${arch}' doesn't match runner arch '${real_arch}'" >&2
        exit 1
fi

cpu_arch=""
if [[ "$real_arch" == "x86_64" ]]; then
        cpu_arch="amd64"
elif [[ "$real_arch" == "aarch64" ]]; then
        cpu_arch="arm64"
fi

base_image="nvidia/cuda:${cuda_ver}-${cuda_type}-${os}"

case $img_type in
        "cibuildwheel")
                docker build --build-arg CPU_ARCH="${cpu_arch}" --build-arg BASE_IMAGE="${base_image}" --pull ./ciwheel -t "${image_to_build}" >&2
                ;;
        "citestwheel")
                docker build --build-arg CPU_ARCH="${cpu_arch}" --build-arg BASE_IMAGE="${base_image}" --pull ./ciwheel -t "${image_to_build}" >&2
                ;;
        "manylinux"*)
                # run in a subshell to redirect all of the innner manylinux/build.sh script wholesale
                (cd ./manylinux
                 build_policy="${img_type}"
                 if [[ "${jetson}" == "yes" ]]; then
                         docker build -f "../jetson/Dockerfile-118" -t "jetson-base" .
                         MANYLINUX_BUILD_FRONTEND="docker" COMMIT_SHA=latest POLICY="${build_policy}" PLATFORM="${real_arch}" BASEIMAGE_OVERRIDE="jetson-base" ./build.sh &&\
                                 docker tag "quay.io/pypa/${build_policy}_${real_arch}" "${image_to_build}"
                 else
                         MANYLINUX_BUILD_FRONTEND="docker" COMMIT_SHA=latest POLICY="${build_policy}" PLATFORM="${real_arch}" BASEIMAGE_OVERRIDE="${base_image}" ./build.sh &&\
                                 docker tag "quay.io/pypa/${build_policy}_${real_arch}" "${image_to_build}"
                 fi
                 cd -) >&2
                ;;
        *)
                echo "Unsupported image build '$img_type'" >&2
                exit 1
esac
