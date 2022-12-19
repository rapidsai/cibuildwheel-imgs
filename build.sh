#!/usr/bin/env bash

set -eou pipefail
set -x

image_to_build="${BUILD_IMAGE:-""}"

if [[ "${image_to_build}" == "" ]]; then
        echo "Must specify BUILD_IMAGE" >&2
        exit 1
fi

# chop it up for informational purposes
img=$(echo "${image_to_build}" | tr "/:" "-")

img_type=$(echo "${img}" | cut -d'-' -f2)
cuda_type=$(echo "${img}" | cut -d'-' -f4)
cuda_ver=$(echo "${img}" | cut -d'-' -f5)
os=$(echo "${img}" | cut -d'-' -f6)
arch=$(echo "${img}" | cut -d'-' -f7)
real_arch=$(uname -m)

if [[ ("$arch" == "amd64" && "$real_arch" != "x86_64") || ("$arch" == "arm64" && "$real_arch" != "aarch64") ]]; then
        echo "Image arch '${arch}' doesn't match runner arch '${real_arch}'" >&2
        exit 1
fi

base_image="nvidia/cuda:${cuda_ver}-${cuda_type}-${os}"

case $img_type in
        "cibuildwheel")
                docker build --build-arg CPU_ARCH="${arch}" --build-arg BASE_IMAGE="${base_image}" --build-arg CIBUILDWHEEL_VERSION=2.8.0 --pull ./cibuildwheel -t "${image_to_build}"
                ;;
        "citestwheel")
                docker build --build-arg CPU_ARCH="${arch}" --build-arg BASE_IMAGE="${base_image}" --pull ./citestwheel -t "${image_to_build}"
                ;;
        "manylinux"*)
                cd ./manylinux
                build_policy="${img_type}"
                COMMIT_SHA=latest POLICY="${build_policy}" PLATFORM="${real_arch}" BASEIMAGE_OVERRIDE="${base_image}" ./build.sh &&\
                        docker tag "quay.io/pypa/${build_policy}_${real_arch}" "${image_to_build}"
                cd -
                ;;
        *)
                echo "Unsupported image build '$img_type'" >&2
                exit 1
esac

# script output is the image (name+tag) that was built
echo -n "${image_to_build}"
