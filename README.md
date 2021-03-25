
[![](https://img.shields.io/docker/v/dirnei/zephyr-rtos-for-ci?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")
[![](https://img.shields.io/docker/image-size/dirnei/zephyr-rtos-for-ci/latest?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")
[![](https://img.shields.io/docker/pulls/dirnei/zephyr-rtos-for-ci?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")
[![](https://img.shields.io/github/license/dirnei/zephyr-rtos-docker-for-ci?style=for-the-badge)](https://cloud.docker.com/repository/docker/dirnei/zephyr-rtos-for-ci/ "View on Docker Hub")

# Docker-Container with preinstalled toolchain for Zephyr-RTOS

This docker image can be used to build ZephyrRTOS projects within a docker container. It has no entrypoint so you have to provide the command by yourself. This e.g. usefull if you want to run this container in a Azure DevOps build pipeline.

> The packages are installed for uid 1001 (Username: vsts)

## Example usage local (powershell)

```docker
docker run -v ${pwd}:/home/vsts/source `
    --user 1001 --rm dirnei/zephyr-rtos-for-ci:latest `
    pwsh -Command Start-Ci -ProjectPath ~/source/zephyr -Board nucleo_f767zi -BuildPath ~/source/build

docker rm zephyr-build-container
```

> Note: Default build path is: `~/build`. It can be changed with -BuildPath

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

## Powershell Script

As I am a Windows developer, I used Powershell inside the linux container because then I can also test the script on my local machine and I think its more fun than other scripting languages :)

To start the provided build script change to the Powershell with `pwsh` and start the script with the method call `Start-Ci`. It can also be started in one go with `pwsh -Command Start-Ci -ProjectPath ~/source/zephyr`. This runs the Start-Ci command in the powershell called from the default shell.

### Arguments

Here is a overview of the available parameter for the `Start-Ci` command:

``` powershell
  [Parameter(Mandatory = $False)]
  [Switch]$VerboseLog,
  [Parameter(Mandatory = $False)]
  [Switch]$Clean,
  [Parameter(Mandatory = $False)]
  [String]$Board,
  [Parameter(Mandatory = $True)]
  [String]$ProjectPath,
  [Parameter(Mandatory = $False)]
  [String]$BuildPath,
  [Parameter(Mandatory = $False)]
  [String[]]$ExtraCFlags,  # <== NEW
  [Parameter(Mandatory = $False)]
  [String[]]$ExtraCxxFlags # <== NEW
```

### NEW: ExtraCFlags and ExtraCxxFlags

Arrays as a paremter in powershell are not that intuitive so here is an example for that:

``` powershell
 Start-Ci -ProjectPath ~/source/zephyr -ExtraCFlags DNO_IP,DOTHER_DEFINE
```

This will define `NO_IP` and `OTHER_DEFINE` in your zephyr project. In other words it will pass those parameters through west through cmake to the compiler.

This was really tricky as I could not find any documentation on how to do this, but it is possible. Here is an example how the west cli call looks:

```
  west build ..... -- -DEXTRA_CFLAGS=-DNO_IP -DOTHER_DEFINE
```
