docker run -v ${pwd}/build:/home/vsts/build/ --user 1001 --rm `
    dirnei/zephyr-rtos-for-ci:latest pwsh -Command Start-Ci -ProjectPath ~/zephyrproject/zephyr/samples/basic/blinky -Board nucleo_f767zi