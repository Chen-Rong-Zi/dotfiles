#!/bin/bash

# 使用 fzf 搜索历史命令
# selected_command=$(history | fzf --tac --preview "echo {}" --preview-window=up:30%)
#
sudo find ~ | fzf --preview="preview  {}" --preview-window=left,30%,border-right
