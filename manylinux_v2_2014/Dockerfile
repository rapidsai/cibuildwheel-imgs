ARG BASE_IMAGE=nvidia/cuda:11.8.0-devel-centos7
FROM ${BASE_IMAGE}

ARG CUDA_VER=11.8.0
ARG PYTHON_VER=3.9.16

ARG DEBIAN_FRONTEND=noninteractive

# Set RAPIDS versions env variables
ENV RAPIDS_CUDA_VERSION="${CUDA_VER}"
ENV RAPIDS_PY_VERSION="${PYTHON_VER}"

ENV PYENV_ROOT="/pyenv" \
    PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN yum update -y && yum install -y epel-release wget gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel xz xz-devel libffi-devel curl git ncurses-devel numactl numactl-devel openssh-clients libcudnn8-devel zip blas-devel lapack-devel protobuf-compiler autoconf automake libtool centos-release-scl scl-utils cmake && yum clean all

# Install tools that have to be installed after the previous install completes.
RUN yum remove -y git && yum install -y https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm && yum install -y git jq devtoolset-11 && yum remove -y endpoint-repo

# Install latest openssl (can't use the package manager because CentOS 7 stopped after openssl 1.0)
RUN pushd tmp && \
    wget https://ftp.openssl.org/source/openssl-1.1.1k.tar.gz && \
    tar -xzvf openssl-1.1.1k.tar.gz &&\
    cd openssl-1.1.1k && \
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared zlib-dynamic && \
    make && \
    make install && \
    popd

# Install sccache
ARG SCCACHE_VERSION=0.5.0
ARG ARCH="x86_64"

RUN curl -o /tmp/sccache.tar.gz \
        -L "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl.tar.gz" && \
        tar -C /tmp -xvf /tmp/sccache.tar.gz && \
        mv "/tmp/sccache-v${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl/sccache" /usr/bin/sccache && \
        chmod +x /usr/bin/sccache

# Set AUDITWHEEL_* env vars for use with auditwheel
ARG POLICY=manylinux_2_17
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
RUN mkdir -p /ucx-src && pushd /ucx-src &&\
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
    popd && \
    rm -rf /ucx-src/

# Install pyenv
RUN curl https://pyenv.run | bash

# Create pyenvs
# TODO: Determine if any cleanup of the pyenv layers is needed to shrink the container
RUN pyenv update

# Need to specify the openssl location because of the install from source
RUN CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib" pyenv install --verbose ${PYTHON_VER}

RUN pyenv global ${PYTHON_VER} && python -m pip install auditwheel patchelf twine && pyenv rehash

RUN echo -e '\
#!/bin/bash\n\
source scl_source enable devtoolset-11\n\
' > /etc/profile.d/enable_devtools.sh

# Install latest gha-tools
RUN wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - | tar -xz -C /usr/local/bin

# Install the AWS CLI
RUN mkdir -p /aws_install && pushd /aws_install && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
    popd && \
    rm -rf /aws_install

# Mark all directories as safe for git so that GHA clones into the root don't
# run into issues
RUN git config --system --add safe.directory '*'

CMD ["/bin/bash"]
