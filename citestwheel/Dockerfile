ARG CUDA_VER=11.8.0
ARG LINUX_VER=ubuntu18.04

ARG BASE_IMAGE=nvidia/cuda:{CUDA_VER}-devel-{LINUX_VER}
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ENV PYENV_ROOT="/pyenv" \
    PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y --no-install-recommends \
        wget curl git jq ssh \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget \
        curl llvm libncursesw5-dev xz-utils tk-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# for pyenv
ARG PY39_VERSION="3.9.16"
ARG PY310_VERSION="3.10.9"

# Install pyenv
RUN curl https://pyenv.run | bash

# Create pyenvs
RUN pyenv update \
    && pyenv install ${PY39_VERSION} \
    && pyenv install ${PY310_VERSION}

ARG CIBUILDWHEEL_VERSION=2.11.3

RUN pyenv virtualenv ${PY310_VERSION} citools

RUN eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)" &&\
        pyenv activate citools && python3 -m pip install awscli twine cibuildwheel==${CIBUILDWHEEL_VERSION}

# Create symlinks of aws/cibuildwheel/twine into isolated dir
RUN mkdir -p /citools-bin &&\
        ln -snf /pyenv/versions/citools/bin/aws /citools-bin/aws &&\
        ln -snf /pyenv/versions/citools/bin/twine /citools-bin/twine &&\
        ln -snf /pyenv/versions/citools/bin/cibuildwheel /citools-bin/cibuildwheel

# make cp39 default
RUN pyenv global ${PY39_VERSION} && python --version

# add bin to path
ENV PATH="/pyenv/versions/${PY39_VERSION}/bin/:$/pyenv/versions/${PY310_VERSION}/bin/:/citools-bin/:$PATH"

# install docker-in-docker
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

ARG CPU_ARCH
RUN echo \
  "deb [arch=${CPU_ARCH} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

COPY citestwheel.sh /citestwheel.sh

# update git > 2.17 
RUN grep '18.04' /etc/issue && bash -c "apt-get install -y software-properties-common && add-apt-repository ppa:git-core/ppa -y && apt-get update && apt-get install --upgrade -y git" || true;

# Install latest gha-tools
RUN wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - \
  | tar -xz -C /usr/local/bin

# git safe directory
RUN git config --system --add safe.directory '*'

CMD ["/bin/bash"]
