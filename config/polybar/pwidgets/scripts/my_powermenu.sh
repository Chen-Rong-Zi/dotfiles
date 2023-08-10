#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

dir="~/.config/polybar/pwidgets/scripts/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme $dir/powermenu.rasi"

# Options
shutdown=" Shutdown"
reboot=" Reboot"
lock=" Lock"
suspend=" Suspend"
logout=" Logout"

# Confirmation
confirm_exit() {
	rofi -dmenu\
        -no-config\
		-i\
		-no-fixed-num-lines\
		-p "Are You Sure? : "\
		-theme $dir/confirm.rasi
}

# Message
msg() {
	rofi -no-config -theme "$dir/message.rasi" -e "Options : yes / y / no / n"
}

# Variable passed to rofi
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
			systemctl poweroff
        ;;
    $reboot)
		ans=$(confirm_exit &)
			systemctl reboot
        ;;
    $lock)
			~/.config/scripts/lock
        ;;
    $suspend)
			systemctl suspend
        ;;
    $logout)
			if [[ "$DESKTOP_SESSION" == "i3" ]]; then
				i3-msg exit
			elif [[ "$DESKTOP_SESSION" == "i3-with-shmlog" ]]; then
				i3-msg exit
			fi
        ;;
esac
