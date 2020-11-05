docker run `
    -v ${pwd}:/home/vsts/source `
    --user 1001 `
    --name zephyr-build-container `
    dirnei/zephyr-rtos-for-ci:latest `
    pwsh -Command Start-Ci -ProjectPath ~/source/zephyr

docker rm zephyr-build-container