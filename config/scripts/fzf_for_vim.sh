#!/bin/bash

# 使用 fzf 搜索历史命令
# selected_command=$(history | fzf --tac --preview "echo {}" --preview-window=up:30%)
#
locate $HOME | fzf -m --preview="preview  {}" --preview-window=left,50%,border-right
