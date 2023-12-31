#!/bin/bash
#
variety &
# https://wiki.archlinux.org/index.php/XDG_Autostart
# exec --no-startup-id dex --autostart --environment i3
killall picom; sleep 0.5; picom -b
cfw &
xfce4-power-manager &
# exec        --no-startup-id sleep 2  ; blueman-applet
sleep 2; /usr/lib/kdeconnectd &
sleep 2.5; fcitx5 &
sleep 3.0; gpaste-client start &
sleep 3.5;notify-send -t 3000 -i manjaro "rongzi, welcome back!" &
dunst -config ~/.config/dunst/dunstrc
