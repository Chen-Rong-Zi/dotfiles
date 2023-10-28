#!/usr/bin/bash
temp=$(awk -F"[][]" '/Left:/ { print $2 " " $4 }' <(amixer sget Master))
IFS=" " read -r volume isMuted <<< "$(echo $temp)"

if [ $isMuted = 'off' ];then
    exec echo MUTED
else
    exec echo $volume
fi

