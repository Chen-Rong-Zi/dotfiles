#! /bin/bash

#  ██████╗ ██████╗ ███╗   ██╗███████╗ ██████╗ ██╗     ███████╗
# ██╔════╝██╔═══██╗████╗  ██║██╔════╝██╔═══██╗██║     ██╔════╝
# ██║     ██║   ██║██╔██╗ ██║███████╗██║   ██║██║     █████╗
# ██║     ██║   ██║██║╚██╗██║╚════██║██║   ██║██║     ██╔══╝
# ╚██████╗╚██████╔╝██║ ╚████║███████║╚██████╔╝███████╗███████╗
#  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚══════╝╚══════╝
# for vim
export EDITOR=$(which vim)
# ansi escape
# <++>
# foreground colors
export fg_black="\e[30m"
export fg_red="\e[31m"
export fg_green="\e[32m"
export fg_yellow="\e[33m"
export fg_blue="\e[34m"
export fg_magenta="\e[35m"
export fg_cyan="\e[36m"
export fg_white="\e[37m"
# background colors
export bg_black="\e[40m"
export bg_red="\e[41m"
export bg_green="\e[42m"
export bg_yellow="\e[43m"
export bg_blue="\e[44m"
export bg_magenta="\e[45m"
export bg_cyan="\e[46m"
export bg_white="\e[47m"
# character type
export origin="\e[0m"
export bold="\e[1m"
export light="\e[2m"
export underline="\e[4m"
export highlight="\e[7m"
export deleteline="\e[9m"
sudo bash -c "ulimit -c 300"


# ██╗  ██╗██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ███████╗
# ╚██╗██╔╝██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ██╔════╝
#  ╚███╔╝ ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     █████╗
#  ██╔██╗ ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ██╔══╝
# ██╔╝ ██╗██║     ██║  ██║╚██████╔╝██║     ██║███████╗███████╗
# ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝

# for chinese display
# export LC_CTYPE=en_US.UTF-8# export LANG="zh_CN.UTF-8"# export LC_CTYPE="zh_CN.UTF-8"# export LC_CTYPE="zh_CN.UTF-8"# export LC_NUMERIC="zh_CN.UTF-8"# export LC_TIME="zh_CN.UTF-8"# export LC_COLLATE="zh_CN.UTF-8"# export LC_MONETARY="zh_CN.UTF-8"# export LC_MESSAGES="zh_CN.UTF-8"# export LC_PAPER="zh_CN.UTF-8"# export LC_NAME="zh_CN.UTF-8"# export LC_ADDRESS="zh_CN.UTF-8"# export LC_TELEPHONE="zh_CN.UTF-8"# export LC_MEASUREMENT="zh_CN.UTF-8"# export LC_IDENTIFICATION="zh_CN.UTF-8"
export LANG="zh_CN.UTF-8"
# export LANG="en_US.UTF-8"
export LC_ALL="zh_CN.UTF-8"

# for fcitx5
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# for screen shot
# <++>
get_shot_path() {
    time=$(date "+%y-%m-%d_%H:%M:%S")
    echo "$time.png"
}
export shot_icon="/usr/share/icons/Papirus/48x48/apps/deepin-screenshot.svg"
export error_icon="/usr/share/icons/Papirus/48x48/apps/script-error.svg"
export manjaro_icon="/usr/share/icons/manjaro/maia/48x48.png"
export notification_id="1234"
export shot_dir="$HOME/Pictures/screenshot"
export -f get_shot_path

# for dwm startup log
# <++>
export dwm_startup_log=$HOME/.log/dwm.log

# others
[[ -n $DISPLAY ]] && xset r rate 225 30
# [[ -n $DISPLAY ]] && source $HOME/.xprofile
echo "$(date)" souring .profile >> $HOME/.log/bash.log

# for usefull functions
source /home/rongzi/.config/scripts/functions.sh
