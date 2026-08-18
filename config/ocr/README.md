# RapidOCR-ONNX 局域网 OCR 服务

基于 [RapidOCR](https://github.com/RapidAI/RapidOCR) (PP-OCRv6, ONNXRuntime) 的局域网 OCR 服务。
三档模型常驻内存，FastAPI 提供 HTTP 接口 + 网页前端，launchd 托管开机自启与崩溃自愈。

## 功能

- **三档模型**：`tiny`(最快) / `small`(均衡) / `medium`(最准)，请求参数 `?model=` 切换，默认 `medium`，启动即全部常驻内存（换档零延迟）
- **鉴权**：共享 token，`X-OCR-Token` 请求头 或 `?token=` 查询参数，恒定时间比较防时序攻击
- **双入参**：multipart 文件上传，或 JSON `{"image": "<base64>", "model": "..."}`
- **双输出**：默认结构化 JSON（box/text/score/model/elapsed_ms），`?format=text` 返回纯文本
- **网页 UI**：拖拽上传、原图画框标注、逐行置信度、一键复制全文
- **资源治理**：并发信号量限流（满载 429 不堆积），RSS 软/硬内存闸门（超硬限自杀，launchd KeepAlive 拉起）
- **安全面收窄**：禁 URL 取图（无 SSRF 面），上传 ≤ 20MB、图片最长边 ≤ 8192px

## 目录结构

```
ocr/
├── README.md
├── models/                        # 下载的 ONNX 模型 (det/rec × 3 档 + cls)
└── service/
    ├── main.py                    # FastAPI 服务入口
    ├── smoke_test.py              # 三档加载 + 推理冒烟测试
    ├── download_models.py         # 模型下载脚本 (SHA256 校验)
    ├── com.local.rapidocr.plist   # launchd 配置 (开机自启 + KeepAlive)
    └── static/
        ├── index.html             # 网页前端
        └── favicon.svg
```

## 快速开始

```bash
# 0. 准备环境 (conda, Python 3.12)
conda create -n rapidocr python=3.12
conda install -n rapidocr -c conda-forge onnxruntime
conda run -n rapidocr pip install rapidocr fastapi "uvicorn[standard]" python-multipart pillow psutil

# 1. 下载模型 (tiny/small/medium 三档 + cls, 共约 177MB)
conda run -n rapidocr python service/download_models.py

# 2. 手动启动 (调试用)
conda run -n rapidocr python service/main.py    # 需设置 OCR_TOKEN 环境变量

# 3. 冒烟测试 (可选参数: 图片路径, 默认 test.png)
conda run -n rapidocr python service/smoke_test.py [图片]
```

## 开机自启 (launchd)

plist 已复制到 `~/Library/LaunchAgents/com.local.rapidocr.plist` 并加载：

```bash
launchctl load  ~/Library/LaunchAgents/com.local.rapidocr.plist   # 启用
launchctl unload ~/Library/LaunchAgents/com.local.rapidocr.plist  # 停用
launchctl list | grep rapidocr                                    # 查看状态
```

- `RunAtLoad` + `KeepAlive`：开机自启、崩溃自动拉起（防重启风暴由 `ThrottleInterval=10` 兜底）
- 日志：`~/Library/Logs/rapidocr.{out,err}.log`
- **修改 token 或端口后需 `launchctl unload` + `load` 重载**

## API 文档

### `GET /health`

```json
{"status": "ok", "models": ["tiny","small","medium"], "rss_mb": 923.3}
```

### `POST /ocr`

| 参数 | 位置 | 说明 |
|------|------|------|
| token | Header `X-OCR-Token` 或 `?token=` | 鉴权（必填，缺失/错误返回 401） |
| model | query / JSON body | `tiny` \| `small` \| `medium`，默认 `medium` |
| format | query | `json`（默认）\| `text` |
| file | multipart | 图片文件 |
| 或 image | JSON body | base64 字符串 |

示例：

```bash
# multipart 上传
curl -X POST "http://<host>:8000/ocr?model=tiny" \
  -H "X-OCR-Token: $TOKEN" -F "file=@test.png"

# JSON base64 + 纯文本输出
curl -X POST "http://<host>:8000/ocr?format=text&token=$TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"image": "<base64>", "model": "medium"}'
```

JSON 响应：

```json
{
  "model": "medium",
  "elapsed_ms": 1106.9,
  "results": [
    {"box": [[36,13],[486,16],[486,76],[36,73]], "text": "你好世界", "score": 0.9944}
  ]
}
```

## 环境变量与资源闸门

| 变量 | 默认 | 说明 |
|------|------|------|
| `OCR_TOKEN` | 无（必填） | 鉴权 token，缺失拒绝启动 |
| `OCR_HOST` | `0.0.0.0` | 监听地址 |
| `OCR_PORT` | `8000` | 监听端口 |
| `OCR_CONCURRENCY` | `2` | 并发推理上限，满载返回 429 |
| `OCR_MEM_SOFT_MB` | `1536` | RSS 软限，超过拒绝新请求 (503) |
| `OCR_MEM_HARD_MB` | `2048` | RSS 硬限，超过自杀退出，launchd 拉起 |

> 稳态 RSS 约 1.1GB（medium 工作内存实测 ~1.25GB，软限须高于此）。

## 安全注意事项

- 当前 token 存放在 plist 中（明文）。**建议部署到可信局域网后立即更换**为强随机值，并 `launchctl unload`/`load` 重载。
- 服务绑定 `0.0.0.0`，仅建议在可信内网暴露，勿直接对公网开放。
- 如需更细粒度权限，可在前端 `static/index.html` 或鉴权逻辑中按需扩展。

## 常见问题

- **启动报 `FATAL: OCR_TOKEN 未设置`**：环境变量未注入，检查 plist 或手动 export。
- **首次推理慢**：onnxruntime 会话按需初始化，首次请求比后续慢属正常。
- **返回 503**：内存超软限，稍后重试；若持续超硬限则进程自杀重启。
