export RESPONSE=$(curl -sb -H "Accept: application/json" "https://api.github.com/repos/zephyrproject-rtos/zephyr/releases/latest")
export SUBSELECT="`echo $(echo $RESPONSE | grep -oP '"tag_name":\s"zephyr-(v\d\.\d\.\d)"[\d|\D]+"draft":\s(\w+),')`"
export VERSION="`echo $SUBSELECT | grep -oP '"tag_name":\s"zephyr-\K(v\d\.\d\.\d)'`"
export IS_DRAFT="`echo $SUBSELECT | grep -oP '"draft":\s\K(\w+)'`"