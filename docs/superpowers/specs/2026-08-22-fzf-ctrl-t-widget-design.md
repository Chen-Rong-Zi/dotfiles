# 设计：重写 Ctrl-T 文件补全 widget（fzf key-bindings.bash）

日期：2026-08-22
状态：已获用户确认

## 背景与问题

`~/.config/shell/key-bindings.bash`（软链到 `config/shell/key-bindings.bash`）是自定义的 fzf
key-bindings。Ctrl-T 绑定到 `fzf-file-widget`，其「用光标下词替换」逻辑有多个缺陷：

1. **行中错乱**：替换逻辑用「从行尾截掉 word 长度字节 + 在光标处插入」，只在「词是行尾最后一段」时勉强可用；光标在行中/行首时命令行被破坏。
2. **中文乱码**：用 `wc -c`/`head -c`（字节）和 `${#word}`（字符）混算长度，非 ASCII 路径错位。
3. **双空格**：选中输出带尾随空格，插入又补一个前导空格。
4. **取消后污染**：fzf 取消返回空时仍执行拼接，插入一个多余空格。
5. **多列取参常开且脆弱**：`FZF_WITH_NTH`/`FZF_ACCEPT_NTH` 默认置为 `1..` 恒传；空值会让 fzf 直接报错（exit 2）。
6. **搜索范围错误**：整词当作 `find` 搜索起点，词不是有效目录时返回空列表（例如 `~/Downloads/foo` 中 `foo` 是文件）。

## 目标行为（用户确认）

### 光标位置决定行为
光标处的「词」以空白为界，按光标切成 `前缀`（光标前）+ `后缀`（光标后）：

| 光标位置 | 行为 |
|---|---|
| 词尾 | 用词的目录部分做搜索范围、末段做 fzf 初始过滤，选中后替换整词 |
| 词中/词首 | 同样的范围+过滤规则，只替换光标前的「前缀」，后缀原样保留 |
| 无词（空行/光标在空白） | 列出当前目录，纯插入到光标处 |

### 搜索规则
- `word` 含 `/`：`typed_dir` = 最后一个 `/` 之前的文本（含 `/`，用于重建路径），`base` = 末段（作为 fzf `-q`）
- `word` 不含 `/`：范围 = `.`（当前目录），`base` = 整词
- `~/` 手工展开为 `$HOME`，不用 `eval`（避免 `$(...)` 注入）

## 关键修复点

1. 字符串切片全部用 bash 字符索引（`${var:0:n}`），不用 `head -c`/`wc -c`。
2. 只替换 `[词起点, 光标)` 这一段，词尾之后（含后缀与行尾）原样拼回。
3. 选中路径用 `%q` 转义、单空格连接、无尾随空格。
4. fzf 取消返回空 → 命令行原样不动。
5. `FZF_WITH_NTH`/`FZF_ACCEPT_NTH` 默认不传，仅当 export 才生效（`${VAR:+--with-nth $VAR}`）。
6. `FZF_CTRL_T_COMMAND` 仍可覆盖整个列表命令（配合 nth 做多列取参）。
7. 复用 `__fzfcmd`（tmux 内走 fzf-tmux）、保留 `--reverse --scheme=path -m` 与 `FZF_DEFAULT_OPTS`。

## 改动范围

仅 `config/shell/key-bindings.bash`：
- 新增 `_fzf_word_bounds`（词边界，字符索引）
- 新增 `_fzf_expand_home`（`~` 展开，无 eval）
- 重写 `__fzf_select__`（接受 typed_dir/scope/query，支持自定义命令与 nth 参数）
- 重写 `fzf-file-widget`（词切割 + 前缀替换 + 后缀保留）
- 更新文件头注释（文档化位置相关行为与新环境变量）

不动：`__fzf_cd__`（Ctrl-V）、Ctrl-R 历史、`_get_word_under_cursor`（C-g 调试绑定）、bashrc、completion.bash。

## 验收标准

- 4 个坏场景（词尾/词中/中文/光标在行首）均得到正确结果
- 路径含空格、多选、fzf 取消均正确
- 不设 FZF_WITH_NTH/FZF_ACCEPT_NTH 时 fzf 不再报错
- 通过非交互模拟验证（`bash -c` 加载函数 + 桩替换 fzf）

## 待实现代码骨架（用于计划参考）

```bash
_fzf_word_bounds() {
  local line="$READLINE_LINE" point="$READLINE_POINT"
  local s="$point" e="$point"   # 必须分两条 local：同一 local 里 s/e 读到的是外层 point（bind -x 下为空）
  while (( s > 0 )) && [[ "${line:s-1:1}" =~ [^[:space:]] ]]; do (( s-- )); done
  if (( e < ${#line} )) && [[ "${line:e:1}" =~ [^[:space:]] ]]; then
    while (( e < ${#line} )) && [[ "${line:e:1}" =~ [^[:space:]] ]]; do (( e++ )); done
  fi
  __fzf_word_start=$s; __fzf_word_end=$e
}

_fzf_expand_home() {
  case "$1" in
    \~) printf '%s' "$HOME" ;;
    \~/*) printf '%s' "$HOME/${1#\~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

__fzf_select__() {
  local typed_dir="$1" scope="$2" query="$3"
  shift 3
  local cmd opts out
  if [[ -n "${FZF_CTRL_T_COMMAND-}" ]]; then
    cmd="$FZF_CTRL_T_COMMAND"
  else
    cmd="command find -L $(printf %q "$scope") -mindepth 1 -printf '%P\n' 2>/dev/null"
  fi
  opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore --reverse --scheme=path ${FZF_DEFAULT_OPTS-} ${FZF_CTRL_T_OPTS-} -m"
  out=$(set +o pipefail; eval "$cmd" |
    FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) -q "$query" "$@" |
    while IFS= read -r item; do
      if [[ -n "$typed_dir" ]]; then
        printf '%s%q ' "$typed_dir" "$item"   # typed 前缀原样保留，只对 item 转义
      else
        printf '%q ' "$item"
      fi
    done)
  printf '%s' "${out% }"
}

fzf-file-widget() {
  local ws we prefix suffix typed_dir base scope word selected
  _fzf_word_bounds
  ws=$__fzf_word_start; we=$__fzf_word_end
  prefix="${READLINE_LINE:ws:READLINE_POINT-ws}"
  suffix="${READLINE_LINE:READLINE_POINT:we-READLINE_POINT}"
  word="$prefix"
  if [[ "$word" == */* ]]; then
    typed_dir="${word%/*}/"; base="${word##*/}"
  else
    typed_dir=""; base="$word"
  fi
  if [[ -z "$typed_dir" ]]; then
    scope='.'        # 词无路径分隔符：在当前目录补全
  else
    d="${typed_dir%/}"
    if [[ -z "$d" ]]; then
      scope='/'      # 词是根路径 `/`
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
```
