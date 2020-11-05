
[![](https://img.shields.io/docker/v/dirnei/zephyr-rtos-for-ci?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")
[![](https://img.shields.io/docker/image-size/dirnei/zephyr-rtos-for-ci/latest?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")
[![](https://img.shields.io/docker/pulls/dirnei/zephyr-rtos-for-ci?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")
[![](https://img.shields.io/github/license/dirnei/zephyr-rtos-docker-for-ci?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")

# PlatformIO container with preinstalled toolchain for zephyr on ststm32 platform

This docker image can be used to build ZephyrRTOS projects within a docker container. It has no entrypoint so you have to provide the command by yourself. This e.g. usefull if you want to run this container in a Azure DevOps build pipeline.

> The packages are installed for uid 1001 (Username: vsts)

## Example usage local (powershell)

```docker
docker run `
    -v ${pwd}:/home/vsts/source `
    --user 1001 `
    --name zephyr-build-container `
    dirnei/zephyr-rtos-for-ci:latest `
    pwsh -Command Start-Ci -ProjectPath ~/source/zephyr

docker rm zephyr-build-container
```

## Example usage Azure DevOps

```yml
# ...
resources:
    containers:
    - container: Zephyr-build
      image: dirnei/zephyr-rots-for-ci:latest
      endpoint: your-service-connection

jobs:
- job: zephyr_build
  displayName: "Build firmware"
  pool:
    vmImage: ubuntu-18.04
  container: platformio
  steps:
# ...
  - script: pwsh -Command Start-Ci -ProjectPath ./zephyr -Board nucleo_f767zi
    displayName: 'Build firmware'
# ....
```

## Build config

If you don't want to specify the board as an argument you can create a ```build.config``` in you root git directory with following content:

```json
{
    "boardname":  "nucleo_f767zi"
}
```

## Project structure

I use the following project structure:

```

|- include
|- lib
|- src
|--- main.c
|- zephyr
|--- CMakeLists.txt
|--- dt_overlay.dts
|--- zephyr_kernel.conf
|- .gitignore
|- azure-pipeline.yml
|- README.md
|- ...

```

I place all zephyr configuration files in a ```./zephyr``` folder. This is also the "entrypoint" for the CI build. If you wan't to use it you have to use the same structure. Or you could provide your own build script based on the [profile.ps1](/profile.ps1) script from me