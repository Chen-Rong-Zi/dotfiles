#!/bin/bash
set -u

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
IMG="${2:-}"
REPLACE_ID=""
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    REPLACE_ID="$1"
else
    IMG="${1:-}"
fi
HOST="http://10.22.33.188:8000"
TOKEN="768b311a99278747ac967b286348699c"
MODEL="tiny"
RESULT_FILE="${OCR_RESULT_FILE:-/tmp/ocr_last.txt}"
notify_cmd="${notify:-notify-send}"
notifyx() { timeout 8 "$notify_cmd" "$@"; }
ICON="/usr/share/swcatalog/icons/archlinux-arch-extra/48x48/gimagereader-gtk_gimagereader.png"
ERR_ICON="${error_icon:-/usr/share/icons/breeze-dark/status/64/dialog-error.svg}"

noti() {
    if [[ -n "$REPLACE_ID" ]]; then
        REPLACE_ID="$(notifyx -p -r "$REPLACE_ID" "$@")"
    else
        REPLACE_ID="$(notifyx -p "$@")"
    fi
}

if [[ ! -f "$IMG" ]]; then
    noti -t 5000 --hint string:app_icon:$ERR_ICON "OCR 失败" "图片不存在: $IMG"
    exit 1
fi

noti -t 5000 --hint string:app_icon:$ICON "OCR 识别中…" "$(basename "$IMG")"

err_tmp=$(mktemp)
http_code=$(curl -sS --max-time 10 -o "$RESULT_FILE" -w "%{http_code}" \
    -X POST "$HOST/ocr?model=$MODEL&format=text" \
    -H "X-OCR-Token: $TOKEN" \
    -F "file=@$IMG" 2>"$err_tmp")
curl_rc=$?
curl_err=$(cat "$err_tmp")
rm -f "$err_tmp"

if [[ $curl_rc -ne 0 ]]; then
    case "$curl_rc" in
        6)  msg="无法解析主机，请检查网络" ;;
        7)  msg="无法连接 OCR 服务器 $HOST" ;;
        28) msg="请求超时（10s），服务器无响应" ;;
        *)  msg="网络错误（curl $curl_rc）：$(printf '%s' "$curl_err" | head -c 80)" ;;
    esac
    noti -t 5000 --hint string:app_icon:$ERR_ICON -A "ocr:$IMG=重试" "OCR 失败" "$msg"
    exit 1
fi

case "$http_code" in
    200)
        text=$(python3 -c 'import sys
t = sys.stdin.read().rstrip("\n")
if len(t) > 200:
    t = t[:200] + "…"
sys.stdout.write(t)' < "$RESULT_FILE")
        noti -t 5000 --hint string:app_icon:$ICON \
            -A "copy=复制" \
            "OCR 结果" "$text"
        ;;
    401) noti -t 5000 --hint string:app_icon:$ERR_ICON -A "ocr:$IMG=重试" "OCR 失败" "鉴权失败（X-OCR-Token 无效）" ;;
    429) noti -t 5000 --hint string:app_icon:$ERR_ICON -A "ocr:$IMG=重试" "OCR 失败" "服务繁忙（并发满载），请稍后重试" ;;
    503) noti -t 5000 --hint string:app_icon:$ERR_ICON -A "ocr:$IMG=重试" "OCR 失败" "服务内存超限，请稍后重试" ;;
    *)   noti -t 5000 --hint string:app_icon:$ERR_ICON -A "ocr:$IMG=重试" "OCR 失败" "服务返回 HTTP $http_code" ;;
esac