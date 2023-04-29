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
        "citestwheel")
                docker build --build-arg CPU_ARCH="${cpu_arch}" --build-arg BASE_IMAGE="${base_image}" --pull ./ciwheel -t "${image_to_build}" >&2
                ;;
        "manylinux_v2"*)
                if [[ ("$os" == *"centos"*) ]]; then
                    docker build --build-arg CPU_ARCH="${cpu_arch}" --build-arg BASE_IMAGE="${base_image}" --pull ./manylinux_v2_centos -t "${image_to_build}" >&2
                else
                    docker build --build-arg CPU_ARCH="${cpu_arch}" --build-arg BASE_IMAGE="${base_image}" --pull ./manylinux_v2_ubuntu -t "${image_to_build}" >&2
                fi
                ;;
        *)
                echo "Unsupported image build '$img_type'" >&2
                exit 1
esac
