#!/bin/bash

# 使用 fzf 搜索历史命令
# selected_command=$(history | fzf --tac --preview "echo {}" --preview-window=up:30%)
#

if [[ $# > 2 ]];then
    locate $1 | fzf --tmux center
    # --preview="preview  {}" --preview-window=right,40%,border-left,wrap
else
    locate $1 | fzf -m --preview="preview  {}" --preview-window=right,40%,border-left,wrap
fi
