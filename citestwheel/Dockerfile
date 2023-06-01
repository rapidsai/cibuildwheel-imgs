ARG CUDA_VER=11.8.0
ARG LINUX_VER=ubuntu18.04

ARG BASE_IMAGE=nvidia/cuda:${CUDA_VER}-devel-${LINUX_VER}
FROM ${BASE_IMAGE}

ARG PYTHON_VER=3.9

ARG DEBIAN_FRONTEND=noninteractive

ENV PYENV_ROOT="/pyenv"
ENV PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y --no-install-recommends \
        wget curl git jq ssh \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget \
        curl llvm libncursesw5-dev xz-utils tk-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install pyenv
RUN curl https://pyenv.run | bash

# Create pyenvs
RUN pyenv update && pyenv install ${PYTHON_VER}

RUN pyenv global ${PYTHON_VER} && python --version

# add bin to path
ENV PATH="/pyenv/versions/${PYTHON_VER}/bin/:$PATH"

# Install the AWS CLI
# Needed to download wheels for running tests
RUN python3 -m pip install awscli

COPY citestwheel.sh /citestwheel.sh

# update git > 2.17 
RUN grep '18.04' /etc/issue && bash -c "apt-get install -y software-properties-common && add-apt-repository ppa:git-core/ppa -y && apt-get update && apt-get install --upgrade -y git" || true;

# Install latest gha-tools
RUN wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - \
  | tar -xz -C /usr/local/bin

# git safe directory
RUN git config --system --add safe.directory '*'

CMD ["/bin/bash"]
