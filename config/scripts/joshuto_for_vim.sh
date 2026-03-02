#!/bin/bash

# 使用 fzf 搜索历史命令
# selected_command=$(history | fzf --tac --preview "echo {}" --preview-window=up:30%)

touch $1
"${HOME}/Project/joshuto/target/release/joshuto" --file-chooser --output-file $1
