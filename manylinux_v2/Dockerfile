ARG BASE_IMAGE=nvidia/cuda:11.8.0-devel-centos7
#arm: ARG BASE_IMAGE=nvidia/cuda:11.8.0-devel-ubuntu18.04
FROM ${BASE_IMAGE}
SHELL ["/bin/bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ENV PYENV_ROOT="/pyenv" \
    PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN if [[ "${BASE_IMAGE}" == *"centos"* ]]; then ON_CENTOS=1; else ON_CENTOS=0; fi

# TODO: Probably better to avoid the conditional for caching layers
RUN if [ "ON_CENTOS" ] ; then yum update -y && yum install -y wget gcc centos-release-scl scl-utils zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel xz xz-devel libffi-devel curl ncurses-devel numactl numactl-devel openssh-clients libcudnn8-devel zip blas-devel lapack-devel protobuf-compiler autoconf automake libtool && yum clean all ; else apt update -y && apt install -y build-essential software-properties-common wget gcc zlib1g-dev libbz2-dev libssl-dev libreadline-dev libsqlite3-dev libffi-dev curl git libncurses5-dev libnuma-dev openssh-client libcudnn8-dev zip libopenblas-dev liblapack-dev protobuf-compiler autoconf automake libtool && rm -rf /var/lib/apt/lists/* ; fi

# Install latest git and compilers (needs a separate repo)
RUN if [ "ON_CENTOS" ] ; then yum remove -y git && yum install -y https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm && yum install -y git devtoolset-11 && yum remove -y endpoint-repo && yum clean all ; else add-apt-repository ppa:git-core/ppa && add-apt-repository ppa:ubuntu-toolchain-r/test && apt update -y && apt install -y git gcc-11 g++-11 && add-apt-repository -r ppa:git-core/ppa && add-apt-repository -r ppa:ubuntu-toolchain-r/test ; fi

RUN if [ ! "ON_CENTOS" ] ; then update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 90 --slave /usr/bin/g++ g++ /usr/bin/g++-11 --slave /usr/bin/gcov gcov /usr/bin/gcov-9 ; fi

# Install latest openssl (can't use the package manager because CentOS 7 stopped after openssl 1.0)
RUN if [ "ON_CENTOS" ] ; then pushd tmp && \
    wget https://ftp.openssl.org/source/openssl-1.1.1k.tar.gz && \
    tar -xzvf openssl-1.1.1k.tar.gz &&\
    cd openssl-1.1.1k && \
    ./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib no-shared zlib-dynamic && \
    make && \
    make install && \
    popd \
    fi

# Install sccache
ARG SCCACHE_VERSION=0.4.2

RUN if [ "ON_CENTOS" ] ; then ARCH="x86_64" ; else ARCH="aarch64" ; fi; curl -o /tmp/sccache.tar.gz \
        -L "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl.tar.gz" && \
        tar -C /tmp -xvf /tmp/sccache.tar.gz && \
        mv "/tmp/sccache-v${SCCACHE_VERSION}-${ARCH}-unknown-linux-musl/sccache" /usr/bin/sccache && \
        chmod +x /usr/bin/sccache

# Install ucx
ARG UCX_VERSION=1.13.0
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

# for pyenv
ARG PY39_VERSION="3.9.16"
ARG PY310_VERSION="3.10.9"

# Install pyenv
RUN curl https://pyenv.run | bash

# Create pyenvs
# TODO: Determine if any cleanup of the pyenv layers is needed to shrink the container
RUN pyenv update

# Need to specify the openssl location because of the install from source
RUN if [ "ON_CENTOS" ] ; then CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib" pyenv install --verbose ${PY39_VERSION}; else pyenv install --verbose ${PY39_VERSION}; fi

RUN if [ "ON_CENTOS" ] ; then CPPFLAGS="-I/usr/include/openssl" LDFLAGS="-L/usr/lib" pyenv install --verbose ${PY10_VERSION}; else pyenv install --verbose ${PY310_VERSION}; fi

RUN pyenv global ${PY39_VERSION} && python -m pip install auditwheel patchelf twine

RUN pyenv global ${PY310_VERSION} && python -m pip install auditwheel patchelf twine

RUN if [ "ON_CENTOS" ] ; then echo -e '\
#!/bin/bash\n\
source scl_source enable devtoolset-11\n\
' > /etc/profile.d/enable_devtools.sh fi

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
