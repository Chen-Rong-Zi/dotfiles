# :Run 隐式 shell 化设计

日期：2026-08-08
状态：已确认（用户批准：全部隐式走 shell、term+debug 都走、标志仅开头识别、--once 仅开头识别）

## 背景与目标

当前 `:Run` 传字符串给 `term_start`/`job_start`，Vim 按空白拆分后**直接执行、不经过 shell**（已实测：`echo hello | tr a-z A-Z` 输出 `hello | tr a-z A-Z`，管道未生效，`|` 作为字面参数传给 `echo`）。因此管道、重定向、`&&`/`||`/`;`、`$VAR`、通配符、反引号等 shell 结构全部不可用。

目标：`:Run` 的命令原样保留引号/管道/空格，整条经 `&shell -c`（当前 `/bin/bash -c`）执行，支持完整 shell 语义。

用户已确认三项决策：

1. **全部命令隐式走 shell**（不设显式标记，也不做元字符自动检测）。
2. **term 与 debug（`-d`）两种模式都走 shell**。
3. **`-i`/`-d`/`--once` 标志只允许出现在命令开头**；`--once` 仅在开头识别（不再像现状在任意位置剥离）。

## 命令格式（改后）

```
:Run [--once] [-i | -d] <任意 shell 命令行>
```

`<命令行>` 原样保留引号与管道，经 `sh -c '<命令行>'` 执行。示例：

```vim
:Run ls | grep foo                " 管道
:Run python3 % 2>&1 | rg error    " 过滤
:Run touch "my file.txt"          " 引号内空格
:Run echo $HOME                   " 变量展开
:Run fastfetch                    " 简单命令行为不变
```

默认 `io -m -eq %`、`-d`/`-i`/`--once`、双向记忆（`g_run_prefill`）、自动运行全部保持。

## 架构改动

### 1. BuildCommand：`%` 替换改为 shellescape + split/join

`CommandRunner.BuildCommand`（mode.vim:108-111）现状：

```vim
return substitute(this.cmd_template, '%', escape(this.filepath, '&\~'), 'g')
```

改为：

```vim
return split(this.cmd_template, '%', v:true)->join(shellescape(this.filepath))
```

- `shellescape()` 处理路径中的空格/`$`/引号，使含特殊字符的路径在 shell 下仍正确。
- 用 split/join 替代 substitute，避免 substitute 替换串元字符（`&`/`\`/`~`）污染 shellescape 输出。
- `DebugMode.BuildCommand` 的自定义命令分支（mode.vim:545）与 makeprg 回退分支（mode.vim:548-550）同样对 `%` 做 shellescape。

### 2. term 模式包装（RunTerm，mode.vim:489）

```vim
botright this.term_nr = term_start([&shell, &shellcmdflag, cmd], option)
```

- cmd 作为**列表元素**传入，实际执行 `sh -c 'cmd'`，不再被空白重拆。
- 已实测：`term_start([&shell, &shellcmdflag, 'echo hello | tr a-z A-Z'], ...)` → 终端输出 `HELLO`。

### 3. debug 模式包装（DebugMode.RunJob，mode.vim:583）

```vim
this.job = job_start([&shell, &shellcmdflag, this.last_cmd], option)
```

### 4. 显示层不变

`last_cmd`（quickfix title）、`g_run_prefill`、`<leader>ir` 预填均显示**裸命令**（不含 `sh -c`、不含 shellescape 引号）。记忆/双向共用/自动运行逻辑零改动。

## 引号与管道保留：`<f-args>` → `<q-args>`

- mode.vim:838 命令定义改为：`command -nargs=* Run ParseRunArgs(<q-args>)`
  - 已实测：`Run echo "a b"` → 收到**一个**字符串 `echo "a b"`（引号原样保留）。
  - 已实测：对 `-nargs=*` 用户命令，`|` 不分割为第二条命令（`Run echo "a b" | Q` 中 `Q` 未执行），用户**直接输入管道无需转义**。
- `ParseRunArgs` 签名改为 `(raw: string)`，改为字符串解析：

```
1. line = trim(raw)；once = false；mode = ''（'term' | 'debug' | 'interactive'）
2. 循环剥离前缀标志（仅开头识别）：
     first = line 首空白分隔 token
     first == '--once' → once = true，剥离该 token
     first == '-d'     → mode = 'debug'，剥离该 token
     first == '-i'     → mode = 'interactive'，剥离该 token
     否则 break（剩余整行即为命令本体，原样保留）
3. 分派：
   - mode == 'interactive' → 注册 CmdwinEnter autocmd 预填默认/上次命令，忽略剩余命令（维持现状）
   - mode == 'debug' 且 line 为空 → 复用 g_run_prefill；为空则回退 &makeprg
   - mode == 'debug' 且 line 非空 → 命令 = line 原样
   - mode == 'term' 且 line 为空 → 自动运行上次命令（无则默认 io -m -eq %）；--once 则只运行不保存
   - mode == 'term' 且 line 非空 → 命令 = line 原样
4. 非 --once 且命令非空时，命令写入 g_run_prefill
```

- 空调用 `:Run` → `<q-args>` 为 `''`，按无参数自动运行处理。
- 用例：`-d --once foo`、`--once -d foo` 均正确（`--once` 与 `-d` 可任意顺序出现在开头）。

## io 交互与既有标志

- `is_io` 判断、`-r`（防重复）/`-s`/`--` 追加逻辑**不动**——只在默认 `io -m -eq %` 时生效，追加后仍作为 cmd 字符串一部分被 shell 包装。
- 前缀 `-s`/`--` 作为自定义命令首词时，与现状一致**字面传给 shell**（不新增标志处理）。
- 手动验证项：默认 `<leader>r`（io 需要 TTY）行为应与现在完全一致。

## 错误处理

- exitval = `sh` 的退出码 = 管道**最后一个命令**的退出码（shell 语义）；quickfix title 照常显示。
- debug 模式输出仍逐行 `caddexpr` 进 quickfix；E906 防护（`ch_status(ch) ==# 'open'`）不变；`err_io:'file'`/`err_name` 不变。

## 测试（headless，复用 probe 技巧）

| 用例 | 预期 |
|------|------|
| `:Run echo hello \| tr a-z A-Z` | term 输出 `HELLO` |
| `:Run -d echo foo \| cat` | quickfix 捕获 `foo` |
| `:Run touch "/tmp/a b.txt"` | 含空格文件创建成功（引号保留） |
| `:Run echo $HOME` | 展开为 `/Users/…` |
| `%` 路径含空格 | 命令执行正确（shellescape 生效） |
| `:Run -d false` | 退出码 1（sh 传播） |
| `--once` 前缀剥离 / 自动运行 / `-i` | 与现状一致 |
| 默认 `io -m -eq %` | 仍走 term，`-r` 逻辑不回归 |

## 边界说明

- `--once` 由"任意位置剥离"收紧为"仅开头识别"，是有意的语义修正（避免吃掉 shell 命令中的 `--once` 参数）。
- 不改动 Grep/Mypy；不新增配置项。
