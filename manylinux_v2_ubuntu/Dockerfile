ARG BASE_IMAGE=nvidia/cuda:11.8.0-devel-ubuntu20.04
FROM ${BASE_IMAGE}

ARG CUDA_VER=11.8.0
ARG PYTHON_VER=3.9

ARG DEBIAN_FRONTEND=noninteractive

# Set RAPIDS versions env variables
ENV RAPIDS_CUDA_VERSION="${CUDA_VER}"
ENV RAPIDS_PY_VERSION="${PYTHON_VER}"

ENV PYENV_ROOT="/pyenv" \
    PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN apt update -y && apt install -y jq build-essential software-properties-common wget gcc zlib1g-dev libbz2-dev libssl-dev libreadline-dev libsqlite3-dev libffi-dev curl git libncurses5-dev libnuma-dev openssh-client libcudnn8-dev zip libopenblas-dev liblapack-dev protobuf-compiler autoconf automake libtool cmake && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:git-core/ppa && add-apt-repository ppa:ubuntu-toolchain-r/test && apt update -y && apt install -y git gcc-9 g++-9 && add-apt-repository -r ppa:git-core/ppa && add-apt-repository -r ppa:ubuntu-toolchain-r/test

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9

# Install sccache
ARG SCCACHE_VERSION=0.5.0
ARG ARCH="aarch64"

RUN curl -o /tmp/sccache.tar.gz \
        -L "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl.tar.gz" && \
        tar -C /tmp -xvf /tmp/sccache.tar.gz && \
        mv "/tmp/sccache-v${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl/sccache" /usr/bin/sccache && \
        chmod +x /usr/bin/sccache

# Set AUDITWHEEL_* env vars for use with auditwheel
ARG POLICY=manylinux_2_31
ENV AUDITWHEEL_POLICY=${POLICY} AUDITWHEEL_ARCH=${ARCH} AUDITWHEEL_PLAT=${POLICY}_${ARCH}

# Set sccache env vars
ENV CMAKE_CUDA_COMPILER_LAUNCHER=sccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=sccache
ENV CMAKE_C_COMPILER_LAUNCHER=sccache
ENV SCCACHE_BUCKET=rapids-sccache-east
ENV SCCACHE_REGION=us-east-2
ENV SCCACHE_IDLE_TIMEOUT=32768
ENV SCCACHE_S3_USE_SSL=true
ENV SCCACHE_S3_NO_CREDENTIALS=false

# Install ucx
ARG UCX_VERSION=1.14.1
RUN mkdir -p /ucx-src && cd /ucx-src &&\
    git clone https://github.com/openucx/ucx -b v${UCX_VERSION} ucx-git-repo &&\
    cd ucx-git-repo && \
    ./autogen.sh && \
    ./contrib/configure-release \
       --prefix=/usr               \
       --enable-mt                 \
       --enable-cma                \
       --enable-numa               \
       --with-gnu-ld               \
       --with-sysroot              \
       --without-verbs             \
       --without-rdmacm            \
       --with-cuda=/usr/local/cuda && \
    CPPFLAGS=-I/usr/local/cuda/include make -j && \
    make install && \
    cd / && \
    rm -rf /ucx-src/

# Install pyenv
RUN curl https://pyenv.run | bash

# Create pyenvs
# TODO: Determine if any cleanup of the pyenv layers is needed to shrink the container
RUN pyenv update

# Need to specify the openssl location because of the install from source
RUN pyenv install --verbose ${PYTHON_VER}

RUN pyenv global ${PYTHON_VER} && python -m pip install auditwheel patchelf twine && pyenv rehash

# Install latest gha-tools
RUN wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - | tar -xz -C /usr/local/bin

# Install the AWS CLI
RUN mkdir -p /aws_install && cd /aws_install && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    cd / && \
    rm -rf /aws_install

# Mark all directories as safe for git so that GHA clones into the root don't
# run into issues
RUN git config --system --add safe.directory '*'

CMD ["/bin/bash"]
