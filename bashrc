#!/bin/bash
# enable the subsequent settings only in interactive sessions case $- in
#   *i*) ;;
#     *) return;;
# esac

# Path to your oh-my-bash installation.
export OSH='/home/rongzi/.oh-my-bash'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="powerline"

# Uncomment the following line to use case-sensitive completion.
# OMB_CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# OMB_HYPHEN_SENSITIVE="false"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_OSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you don't want the repository to be considered dirty
# if there are untracked files.
# SCM_GIT_DISABLE_UNTRACKED_DIRTY="true"

# Uncomment the following line if you want to completely ignore the presence
# of untracked files in the repository.
# SCM_GIT_IGNORE_UNTRACKED="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.  One of the following values can
# be used to specify the timestamp format.
# * 'mm/dd/yyyy'     # mm/dd/yyyy + time
# * 'dd.mm.yyyy'     # dd.mm.yyyy + time
# * 'yyyy-mm-dd'     # yyyy-mm-dd + time
# * '[mm/dd/yyyy]'   # [mm/dd/yyyy] + [time] with colors
# * '[dd.mm.yyyy]'   # [dd.mm.yyyy] + [time] with colors
# * '[yyyy-mm-dd]'   # [yyyy-mm-dd] + [time] with colors
# If not set, the default value is 'yyyy-mm-dd'.
# HIST_STAMPS='yyyy-mm-dd'

# Uncomment the following line if you do not want OMB to overwrite the existing
# aliases by the default OMB aliases defined in lib/*.sh
# OMB_DEFAULT_ALIASES="check"

# Would you like to use another custom folder than $OSH/custom?
# OSH_CUSTOM=/path/to/new-custom-folder

# To disable the uses of "sudo" by oh-my-bash, please set "false" to
# this variable.  The default behavior for the empty value is "true".
OMB_USE_SUDO=true

# To enable/disable display of Python virtualenv and condaenv
OMb_PROMPT_SHOW_PYTHON_VENV=true  # enable
# OMB_PROMPT_SHOW_PYTHON_VENV=false # disable

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
completions=(
  git
  composer
  ssh
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
# Custom aliases may be added to ~/.oh-my-bash/custom/aliases/
# Example format: aliases=(vagrant composer git-avh)
# Add wisely, as too many aliases slow down shell startup.
aliases=(
  general
)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  bashmarks
)

# Which plugins would you like to conditionally load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format:
#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

source "$OSH"/oh-my-bash.sh

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-bash libs,
# plugins, and themes. Aliases can be placed here, though oh-my-bash
# users are encouraged to define aliases within the OSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias bashconfig="mate ~/.bashrc"
# alias ohmybash="mate ~/.oh-my-bash"

alias chrome="google-chrome-stable"
alias vi="vim -o"
alias vim="vim -o"
alias la="exa --icons -alh --color=auto "
alias ll="exa --icons -alg --color=auto"
alias ls="exa  --color=auto"
alias l="exa -lh --icons"
alias please="sudo"
alias ra="ranger "
alias sudo="sudo -E"
alias sduo="sudo -E"
alias ef="neofetch"
alias scrot="scrot ~/Pictures/screenshot/%y-%m-%d_%T.jpg"
alias volume="pavucontrol"
alias s="neofetch"
alias tl="tldr"
alias ala="swl alacritty &"
alias swl="swallow"
alias trans="trans en:zh-CH -show-prompt-message n -show-original-dictionary N -show-alternatives n -show-translation-phonetics n -show-original-phonetics n -no-warn -show-translation-phonetics N -show-languages n -show-dictionary n"
alias rtrans="trans zh-CH:en -show-prompt-message n -show-original-dictionary N -show-alternatives n -show-translation-phonetics n -show-original-phonetics n -no-warn -show-translation-phonetics N -show-languages n -show-dictionary n"
alias dtrans="trans en:zh-CH -show-prompt-message n -show-original-dictionary Y -show-alternatives Y -show-translation-phonetics Y -show-original-phonetics Y -no-warn -show-translation-phonetics Y -show-languages Y -show-dictionary Y"
alias ags="xargs"
# alias cfw="~/.config/usr/'Clash for Windows-0.18.5-x64-linux'/cfw"
# 打开终端自动开启代理
alias setproxy="export https_proxy=http://127.0.0.1:7890;export http_proxy=http://127.0.0.1:7890;export all_proxy=socks5://127.0.0.1:7890"
alias unsetproxy="unset ALL_PROXY; echo 'UNSET PROXY SUCCESS!!!'"
alias shot="import $image_path"
alias rm="rm -i"
alias restore="io ~/cProgram/fulfill.c"
alias cc="gcc -Wall -Werror -O2"
alias git-log="git log --all --graph --decorate --oneline"
alias py="python3"
alias ipy="ipdb"
alias open="pcmanfm"
alias nmtui="rfkill unblock wlan && nmtui"
alias gdb="gdb -q"
alias tm="tmux"
alias gs="git status"
alias ta="tmux attach"

export image_path="/home/rongzi/Pictures/screenshot/$(date "+%y-%m-%d_%H:%M:%S").jpg"
# export MANPAGER="vim - -MR +'set filetype=man'"
export token="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"
export EDITOR=/usr/bin/vim
export PATH=$PATH:/home/rongzi/cProgram
export LC_CTYPE=zh_CN.UTF-8
# export https_proxy="https://127.0.0.1:8090"
# export http_proxy="http://127.0.0.1:8090"
# export https_proxy=http://127.0.0.1:8090;export http_proxy=http://127.0.0.1:8090;export all_proxy=socks5://127.0.0.1:8090

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export LC_CTYPE=zh_CN.UTF-8
export RANGER_LOAD_DEFAULT_RC=FALSE
export RANGER_DEVICONS_SEPARATOR="  "
export LogoutCommand="i3-msg exit"
export CM_DIR=/run/user/1000
export FZF_DEFAULT_COMMAND="sudo find ~"
export FZF_DEFAULT_OPTS="--bind ctrl-j:accept"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
 --color=fg:#d0d0d0,hl:#5f87af
 --color=fg+:#d0d0d0,hl+:#5fd7ff
 --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
 --color=marker:#87ff00,spinner:#af5fff,header:#87afaf'
# junegunn/seoul256.vim (dark)
# export FZF_DEFAULT_OPTS='--color=bg+:#3F3F3F,bg:#4B4B4B,border:#6B6B6B,spinner:#98BC99,hl:#719872,fg:#D9D9D9,header:#719872,info:#BDBB72,pointer:#E12672,marker:#E17899,fg+:#D9D9D9,preview-bg:#3F3F3F,prompt:#98BEDE,hl+:#98BC99'
export bin="/home/rongzi/cProgram/a.out"
export BROWSER="google-chrome-stable"
setproxy

# If not running interactively, do not do anything

# python-symengine: optimized backend, set USE_SYMENGINE=1 to use
export USE_SYMENGINE=1
# PS1="MYTestPrompt> "
export core_pattern="$(cat /proc/sys/kernel/core_pattern)"
export core_dir="/home/rongzi/Downloads/Coredump"
debug() {
    export core_name="$(/bin/ls -r $core_dir| head -n 1)"
    export core_path="$core_dir/$core_name"
    gdb $bin "$core_path"
}

fj() {
    path=$(fzf)
    if [[ $(file $path | awk  '{print $2}') == 'directory' ]];then
        joshuto $path
    else
        joshuto $( echo $path | awk -F / -v OFS=/ '{$NF="";print}' ) 
    fi
}

rn() {
    if [[ $# -eq 0 ]]; then
        python3 -c "a=list(range(10));print(a)"
    elif [[ $# -eq 1 ]]; then
        python3 -c "a=list(range($1));print(a)"
    elif [[ $# -eq 2 ]]; then
        python3 -c "a=list(range($1, $2));print(a)"
    elif [[ $# -eq 3 ]]; then
        python3 -c "a=list(range($1, $2, $3));print(a)"
    elif [[ $# -eq 4 ]]; then
        python3 -c "a=set(list(range($1, $2, $3)));print(a)"
    fi
}

# attach() {
#     bg
#     disown
#     export pid=$(jobs -p | cut -d ' ' -f1)
#     tmux
#     sudo sysctl -w kernel.yama.ptrace_scope=0
# #     reptyr $pid
# }

vman() {
#     export MANPAGER="col -b" # for FreeBSD/MacOS

    # Make it read-only
    eval '[[ -n "$(man $@)" ]]  &&  man $@ | vim -MR +"set filetype=man" -'
}

pp() {
    target_pid="$1"
    sleep_interval=5  # 休眠间隔，以避免浪费CPU性能

    while true; do
        kill -0 $target_pid 2>/dev/null
        if  [[ $? -eq 1 ]]; then
            echo $1
            echo "进程 $target_pid 已结束"
            break
        fi
        sleep "$sleep_interval"
        echo 'still alive'
    done
}

if [[ -z $TMUX ]]; then
    tmux
fi


if [ -z "$DISPLAY" ] && [ $(who | grep -oE tty[2-6] | wc -l ) -ge 1 ]; then
    setfont ter-228b.psf.gz
fi

source $HOME/.config/broot/launcher/bash/br
source $HOME/.config/shell/key-bindings.bash
source $HOME/.config/scripts/marco.sh
# alias io="gcc -o /home/rongzi/cProgram/a.out hello_world.c  -lncurses;a.out"
