ARG BASE_IMAGE=nvidia/cuda:11.5.1-runtime-ubuntu18.04
FROM ${BASE_IMAGE}

ARG DEBIAN_FRONTEND=noninteractive

ENV PYENV_ROOT="/pyenv" \
    PATH="/pyenv/bin:/pyenv/shims:$PATH"

RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y --no-install-recommends \
        wget curl git \
        make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget \
        curl llvm libncursesw5-dev xz-utils tk-dev \
        libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Install pyenv
RUN curl https://pyenv.run | bash

# Install gha-tools
RUN wget https://github.com/rapidsai/gha-tools/releases/latest/download/tools.tar.gz -O - \
  | tar -xz -C /usr/local/bin

# Create pyenvs for 3.8 and 3.9
RUN pyenv update \
    && pyenv install 3.8.15 \
    && pyenv install 3.9.15

# create symlinks to python versions
RUN ln -snf /pyenv/versions/3.8.15/bin/python3 /usr/bin/python-cp38 &&\
        ln -snf /pyenv/versions/3.9.15/bin/python3 /usr/bin/python-cp39

ARG CIBUILDWHEEL_VERSION=2.8.0

# set up each python version
RUN python-cp38 -m pip install awscli twine cibuildwheel==${CIBUILDWHEEL_VERSION} &&\
        python-cp39 -m pip install awscli twine cibuildwheel==${CIBUILDWHEEL_VERSION}

# make cp38 default
RUN pyenv global 3.8.15 && python --version

# add bin to path
ENV PATH="/pyenv/versions/3.8.15/bin/:/pyenv/versions/3.9.15/bin/:$PATH"

CMD ["/bin/bash"]
