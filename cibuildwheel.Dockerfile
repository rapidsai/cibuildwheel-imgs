ARG BASE_IMAGE=nvidia/cuda:11.5.1-runtime-ubuntu18.04
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ENV PYENV_ROOT="/pyenv" \
    PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y --no-install-recommends \
        wget curl git jq \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget \
        curl llvm libncursesw5-dev xz-utils tk-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install pyenv
RUN curl https://pyenv.run | bash

# Create pyenvs for 3.8 and 3.9
RUN pyenv update \
    && pyenv install 3.8.15 \
    && pyenv install 3.9.15

ARG CIBUILDWHEEL_VERSION=2.8.0

# set up each python version
RUN /pyenv/versions/3.8.15/bin/python3 -m pip install awscli twine cibuildwheel==${CIBUILDWHEEL_VERSION} &&\
        /pyenv/versions/3.9.15/bin/python3 -m pip install awscli twine cibuildwheel==${CIBUILDWHEEL_VERSION}

# make cp38 default
RUN pyenv global 3.8.15 && python --version

# add bin to path
ENV PATH="/pyenv/versions/3.8.15/bin/:/pyenv/versions/3.9.15/bin/:$PATH"

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

# update git > 2.17 
RUN grep '18.04' /etc/issue && bash -c "apt-get install -y software-properties-common && add-apt-repository ppa:git-core/ppa -y && apt-get update && apt-get install --upgrade -y git" || true;

# Install latest gha-tools
RUN wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - \
  | tar -xz -C /usr/local/bin

# git safe directory
RUN git config --system --add safe.directory '*'

CMD ["/bin/bash"]
