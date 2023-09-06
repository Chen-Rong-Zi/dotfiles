# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Path to your oh-my-bash installation.
export OSH='/home/rongzi/.oh-my-bash'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="axin"

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
# OMB_PROMPT_SHOW_PYTHON_VENV=true  # enable
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
export image_path="/home/rongzi/Pictures/screenshot/$(date "+%y-%m-%d_%H:%M:%S").jpg"

alias chrome="google-chrome-stable"
alias vi=vim
alias la="exa -alh --color=auto --icons"
alias ls="exa  --color=auto --icons"
alias l="exa -lh"
alias please="sudo"
alias ra="ranger "
alias sudo="sudo -E"
alias ef="neofetch"
alias scrot="scrot ~/Pictures/screenshot/%y-%m-%d_%T.jpg"
alias volume="pavucontrol"
alias s="neofetch"
alias tl="tldr"
alias ala="swl alacritty &"
alias swl="swallow"
alias trans="trans en:zh-CH -show-prompt-message n -show-original-dictionary N -show-alternatives n -show-translation-phonetics n -show-original-phonetics n -no-warn -show-translation-phonetics N -show-languages n -show-dictionary n"
alias rtrans="trans zh-CH:en -show-prompt-message n -show-original-dictionary N -show-alternatives n -show-translation-phonetics n -show-original-phonetics n -no-warn -show-translation-phonetics N -show-languages n -show-dictionary n"
alias dtrans="trans en:zh-CH -show-prompt-message n -show-original-dictionary Y -show-alternatives Y -show-translation-phonetics Y -show-original-phonetics Y -no-warn -show-translation-phonetics Y -show-languages n -show-dictionary Y"
alias ags="xargs"
# alias cfw="~/.config/usr/'Clash for Windows-0.18.5-x64-linux'/cfw"
# 打开终端自动开启代理
alias setproxy="export https_proxy=http://127.0.0.1:7890;export http_proxy=http://127.0.0.1:7890;export all_proxy=socks5://127.0.0.1:7890"
alias unsetproxy="unset ALL_PROXY; echo 'UNSET PROXY SUCCESS!!!'"
alias shot="import $image_path"
alias rm="rm -i"
alias tm="if [ -z "$TMUX" ] && [ -n "$DISPLAY" ];then
              tmux
          fi"
alias restore="io ~/cProgram/fulfill.c"
alias cc="gcc -Wall -Werror -O2"
alias git-graph=git log --all --graph --decorate --oneline

export token=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
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
setproxy
export CM_DIR=/run/user/1000

if [ -z "$DISPLAY" ] && [ $(who | grep -oE tty[2-6] | wc -l ) -ge 1 ]; then
    setfont ter-228b.psf.gz
fi

# If not running interactively, do not do anything
export img=/run/media/rongzi/9022EA7A22EA64A6/Users/Administrator/Desktop/科大讯飞X1Pro-远程服务破解系统/system.img
