# cibuildwheel-imgs

This repository contains all images used to build [RAPIDS pip wheel](https://rapids.ai/pip) releases.

* `citestwheel` images are for running tests
* `manylinux` images are for building manylinux-compliant wheels. They are also used to build pure-Python wheels, and for publishing wheels with twine

Current images:

| Image | Label | x86_64 | aarch64 |
| :- | :- | :- | :- |
| rapidsai/manylinux_v2_2_31 | cuda-devel-12.0.1-ubuntu20.04 |  | :heavy_check_mark: |
|  | cuda-devel-11.8.0-ubuntu20.04 |  | :heavy_check_mark: |
| rapidsai/manylinux_v2_2014 | cuda-devel-12.0.1-centos7 | :heavy_check_mark: | |
|  | cuda-devel-11.8.0-centos7 | :heavy_check_mark: | |
| rapidsai/citestwheel | cuda-devel-11.8.0-ubuntu18.04 | :heavy_check_mark: | |
|  | cuda-devel-12.0.1-ubuntu18.04 | :heavy_check_mark: | |
|  | cuda-devel-11.8.0-ubuntu20.04 | | :heavy_check_mark: |
|  | cuda-devel-12.0.1-ubuntu20.04 | | :heavy_check_mark: |

Legacy images (no longer rebuilt, used for 22.10, 22.12):

| Image | Label | x86_64 | aarch64 |
| :- | :- | :- | :- |
| rapidsai/cibuildwheel | cuda-runtime-11.5.1-ubuntu18.04 | :heavy_check_mark: | |
|  | cuda-runtime-11.5.1-ubuntu20.04 | | :heavy_check_mark: |
| rapidsai/manylinux_2_31 | cuda-devel-11.7.1-ubuntu20.04 |  | :heavy_check_mark: |
|  | cuda-devel-11.5.1-ubuntu20.04 |  | :heavy_check_mark: |
| rapidsai/manylinux2014 | cuda-devel-11.7.1-centos7 | :heavy_check_mark: | |
|  | cuda-devel-11.5.1-centos7 | :heavy_check_mark: | |
| rapidsai/citestwheel | cuda-devel-11.5.1-ubuntu18.04 | :heavy_check_mark: | |
| | cuda-devel-11.5.1-ubuntu20.04 |  | :heavy_check_mark: |

Legacy images (no longer rebuilt, used for 23.02, 23.04):

| Image | Label | x86_64 | aarch64 |
| :- | :- | :- | :- |
| rapidsai/cibuildwheel | cuda-runtime-11.8.0-ubuntu20.04 | :heavy_check_mark: | :heavy_check_mark: |
| rapidsai/manylinux_2_31 | cuda-devel-12.0.1-ubuntu20.04 |  | :heavy_check_mark: |
|  | cuda-devel-11.8.0-ubuntu20.04 |  | :heavy_check_mark: |
| rapidsai/manylinux2014 | cuda-devel-12.0.1-centos7 | :heavy_check_mark: | |
|  | cuda-devel-11.8.0-centos7 | :heavy_check_mark: | |
