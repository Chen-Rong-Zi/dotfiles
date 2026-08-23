#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.bash
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS
# - $FZF_WITH_NTH / $FZF_ACCEPT_NTH  (default off; enable column extraction with FZF_CTRL_T_COMMAND)
#
# CTRL-T is position-aware:
#   * word end        -> dirname of the word is the search scope, last segment is the
#                        fzf query, and the whole word is replaced by the selection
#   * middle / start  -> only the text before the cursor is replaced, the suffix is kept
#   * no word         -> lists the current directory, inserts the selection at the cursor

[[ $- =~ i ]] || return 0

# Define a function to get the word under the cursor and print it
_get_word_under_cursor() {
    local line="${READLINE_LINE}"
    local point="${READLINE_POINT}"
    local word=""

    # Find the start of the word
    local start="$point"
    while (( start > 0 )) && [[ "${line:start-1:1}" =~ [^[:space:]] ]]; do
        (( start-- ))
    done

    # Find the end of the word
    local end="$point"
    while (( end < ${#line} )) && [[ "${line:end:1}" =~ [^[:space:]] ]]; do
        (( end++ ))
    done

    word="${line:start:end-start}"
    echo $word
}

# Bind a key sequence (e.g., Ctrl-g) to execute the function
bind -x '"\C-g":_get_word_under_cursor'

# Key bindings
# ------------
# Word boundaries under the cursor (character indexes); sets __fzf_word_start/end.
# A cursor sitting on whitespace (or at the end of the line) binds to the word on the left.
_fzf_word_bounds() {
  local line="$READLINE_LINE" point="$READLINE_POINT"
  local s="$point" e="$point"   # separate stmt: s/e must see the local point, not an outer one
  while (( s > 0 )) && [[ "${line:s-1:1}" =~ [^[:space:]] ]]; do (( s-- )); done
  if (( e < ${#line} )) && [[ "${line:e:1}" =~ [^[:space:]] ]]; then
    while (( e < ${#line} )) && [[ "${line:e:1}" =~ [^[:space:]] ]]; do (( e++ )); done
  fi
  __fzf_word_start=$s
  __fzf_word_end=$e
}

# Expand a leading ~ to $HOME without eval (avoids $(...) injection from the command line).
_fzf_expand_home() {
  case "$1" in
    \~) printf '%s' "$HOME" ;;
    \~/*) printf '%s' "$HOME/${1#\~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

# $1 typed_dir - text prefix kept in the result (e.g. "~/Downloads/"), or ""
# $2 scope     - expanded search root ("." when completing a bare name)
# $3 query     - initial fzf query (last path segment); may be ""
# remaining args are passed through to fzf (e.g. --with-nth / --accept-nth)
__fzf_select__() {
  local typed_dir="$1" scope="$2" query="$3"
  shift 3
  local cmd opts out
  if [[ -n "${FZF_CTRL_T_COMMAND-}" ]]; then
    cmd="$FZF_CTRL_T_COMMAND"
  else
    # BSD find (macOS) 不支持 -printf；cd 进 scope 后 find -print + sed
    # 得到同样的相对路径列表，GNU/Linux 亦兼容，故无需区分平台。
    cmd="(cd $(printf %q "$scope") 2>/dev/null && find -L . -mindepth 1 -print 2>/dev/null) | sed 's|^\./||'"
  fi
  opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse --scheme=path ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} -m"
  out=$(set +o pipefail; eval "$cmd" |
    FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) -q "$query" "$@" |
    while IFS= read -r item; do
      if [[ -n "$typed_dir" ]]; then
        printf '%s%q ' "$typed_dir" "$item"   # keep typed prefix as-is; escape only the item
      else
        printf '%q ' "$item"
      fi
    done)
  printf '%s' "${out% }"
}

__fzfcmd() {
  [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  local ws we prefix suffix typed_dir base scope word selected d
  _fzf_word_bounds
  ws=$__fzf_word_start
  we=$__fzf_word_end
  prefix="${READLINE_LINE:ws:READLINE_POINT-ws}"
  suffix="${READLINE_LINE:READLINE_POINT:we-READLINE_POINT}"
  word="$prefix"
  if [[ "$word" == */* ]]; then
    typed_dir="${word%/*}/"
    base="${word##*/}"
  else
    typed_dir=""
    base="$word"
  fi
  if [[ -z "$typed_dir" ]]; then
    scope='.'   # word has no path separator: complete in the current directory
  else
    d="${typed_dir%/}"
    if [[ -z "$d" ]]; then
      scope='/'   # typed_dir was just "/" (the word is the root path)
    else
      scope="$(_fzf_expand_home "$d")"
    fi
  fi
  local nth
  nth=()
  [[ -n "${FZF_WITH_NTH-}" ]] && nth+=(--with-nth "$FZF_WITH_NTH")
  [[ -n "${FZF_ACCEPT_NTH-}" ]] && nth+=(--accept-nth "$FZF_ACCEPT_NTH")
  selected="$(__fzf_select__ "$typed_dir" "$scope" "$base" "${nth[@]}")"
  [[ -n "$selected" ]] || return
  READLINE_LINE="${READLINE_LINE:0:ws}${selected}${suffix}${READLINE_LINE:we}"
  READLINE_POINT=$(( ws + ${#selected} + ${#suffix} ))
}

__fzf_cd__() {
  local cmd opts dir
  cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | command cut -b3-"}"
  opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse --scheme=path ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-} +m"
  dir=$(set +o pipefail; eval "$cmd" | FZF_DEFAULT_OPTS="$opts" $(__fzfcmd)) && printf 'builtin cd -- %q' "$dir"
}

if command -v perl > /dev/null; then
  __fzf_history__() {
    local output opts script
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
    script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
    output=$(
      set +o pipefail
      builtin fc -lnr -2147483648 |
        last_hist=$(HISTTIMEFORMAT='' builtin history 1) command perl -n -l0 -e "$script" |
        FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }
else # awk - fallback for POSIX systems
  __fzf_history__() {
    local output opts script n x y z d
    if [[ -z $__fzf_awk ]]; then
      __fzf_awk=awk
      # choose the faster mawk if: it's installed && build date >= 20230322 && version >= 1.3.4
      IFS=' .' read n x y z d <<< $(command mawk -W version 2> /dev/null)
      [[ $n == mawk ]] && (( d >= 20230302 && (x *1000 +y) *1000 +z >= 1003004 )) && __fzf_awk=mawk
    fi
    opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
    [[ $(HISTTIMEFORMAT='' builtin history 1) =~ [[:digit:]]+ ]]    # how many history entries
    script='function P(b) { ++n; sub(/^[ *]/, "", b); if (!seen[b]++) { printf "%d\t%s%c", '$((BASH_REMATCH + 1))' - n, b, 0 } }
    NR==1 { b = substr($0, 2); next }
    /^\t/ { P(b); b = substr($0, 2); next }
    { b = b RS $0 }
    END { if (NR) P(b) }'
    output=$(
      set +o pipefail
      builtin fc -lnr -2147483648 2> /dev/null |   # ( $'\t '<lines>$'\n' )* ; <lines> ::= [^\n]* ( $'\n'<lines> )*
        command $__fzf_awk "$script"           |   # ( <counter>$'\t'<lines>$'\000' )*
        FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
    ) || return
    READLINE_LINE=${output#*$'\t'}
    if [[ -z "$READLINE_POINT" ]]; then
      echo "$READLINE_LINE"
    else
      READLINE_POINT=0x7fffffff
    fi
  }
fi

# Required to refresh the prompt after fzf
bind -m emacs-standard '"\er": redraw-current-line'

bind -m vi-command '"\C-z": emacs-editing-mode'
bind -m vi-insert '"\C-z": emacs-editing-mode'
bind -m emacs-standard '"\C-z": vi-editing-mode'

if (( BASH_VERSINFO[0] < 4 )); then
  # CTRL-T - Paste the selected file path into the command line
  # bind -m emacs-standard '"\C-t": " \C-b\C-k \C-u`__fzf_select__`\e\C-e\er\C-a\C-y\C-h\C-e\e \C-y\ey\C-x\C-x\C-f"'
  # bind -m emacs-standard '"\C-t": "`__fzf_select__`"'
  # bind -m vi-command '"\C-t": "\C-z\C-t\C-z"'
  # bind -m vi-insert '"\C-t": "\C-z\C-t\C-z"'

  # CTRL-R - Paste the selected command from history into the command line
  bind -m emacs-standard '"\C-r": "\C-e \C-u\C-y\ey\C-u`__fzf_history__`\e\C-e\er"'
  bind -m vi-command '"\C-r": "\C-z\C-r\C-z"'
  bind -m vi-insert '"\C-r": "\C-z\C-r\C-z"'
else
  # CTRL-T - Paste the selected file path into the command line
  bind -m emacs-standard -x '"\C-t": fzf-file-widget'
  bind -m vi-command -x '"\C-t": fzf-file-widget'
  bind -m vi-insert -x '"\C-t": fzf-file-widget'

  # CTRL-R - Paste the selected command from history into the command line
  bind -m emacs-standard -x '"\C-r": __fzf_history__'
  bind -m vi-command -x '"\C-r": __fzf_history__'
  bind -m vi-insert -x '"\C-r": __fzf_history__'
fi

# ALT-C - cd into the selected directory
bind -m emacs-standard '"\C-v": " \C-b\C-k \C-u`__fzf_cd__`\e\C-e\er\C-m\C-y\C-h\e \C-y\ey\C-x\C-x\C-d"'
bind -m vi-command '"\C-v": "\C-z\ec\C-z"'
bind -m vi-insert '"\C-v": "\C-z\ec\C-z"'
