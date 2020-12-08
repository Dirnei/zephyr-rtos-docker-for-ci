FROM python:3.9.0-buster

ARG ZEPHYR_VERSION=master
ARG ZEPHYR_SOURCE=https://github.com/zephyrproject-rtos/zephyr.git

# add build user
RUN groupadd -g 1001 vsts
RUN useradd --gid 1001 --uid 1001 vsts
RUN mkdir -p /home/vsts
RUN chown vsts:vsts /home/vsts

ENV PATH=${PATH}:/home/vsts/.local/bin

#powershell (for running build script)
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y --no-install-recommends cmake ninja-build powershell

# install tool-chain for user vsts
USER vsts:vsts

WORKDIR /home/vsts

RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2 \
  && tar xpf gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2 && rm gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2

ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/home/vsts/gcc-arm-none-eabi-9-2020-q2-update

RUN pip3 install --user -U west

RUN mkdir ~/zephyrproject && mkdir ~/zephyrproject/zephyr && mkdir ~/zephyrproject/.west
COPY ./config ./zephyrproject/.west/config

RUN git clone --depth 1 -b ${ZEPHYR_VERSION} ${ZEPHYR_SOURCE} ~/zephyrproject/zephyr && cd ~/zephyrproject/zephyr && west update && find ~/zephyrproject -type d -and -name ".git" | xargs rm -rf
RUN pip3 install --user -r ~/zephyrproject/zephyr/scripts/requirements.txt

COPY ./profile.ps1 ./.config/powershell/

USER root:root
RUN chown vsts:vsts /home/vsts/zephyrproject/.west/config

# Delete entrypoint of parent containers (required by Azure Pipelines)
ENTRYPOINT []