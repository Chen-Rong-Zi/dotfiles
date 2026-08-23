#!/bin/bash
set -u

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
IMG="${3:-}"
REPLACE_ID=""
RETRY=0
if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    REPLACE_ID="$1"
    if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
        RETRY="$2"
        IMG="${3:-}"
    else
        IMG="${2:-}"
    fi
else
    IMG="${1:-}"
fi
HOST="http://10.22.33.188:8000"
TOKEN="768b311a99278747ac967b286348699c"
MODEL="tiny"
RESULT_FILE="${OCR_RESULT_FILE:-/tmp/ocr_last.txt}"
notify_cmd="${notify:-notify-send}"
ICON="/usr/share/swcatalog/icons/archlinux-arch-extra/48x48/gimagereader-gtk_gimagereader.png"
ERR_ICON="${error_icon:-/usr/share/icons/breeze-dark/status/64/dialog-error.svg}"

noti() {
    local action="" fifo nid
    if [[ "${1:-}" != -* ]]; then
        action="$1"
        shift
    fi
    fifo=$(mktemp -u /tmp/ocr_nid.XXXXXX)
    mkfifo "$fifo"
    if [[ -n "$REPLACE_ID" ]]; then
        "$notify_cmd" -p -r "$REPLACE_ID" "$@" >"$fifo" 2>/dev/null &
    else
        "$notify_cmd" -p "$@" >"$fifo" 2>/dev/null &
    fi
    exec 3<"$fifo"
    IFS= read -r nid <&3
    [[ -n "$nid" ]] && REPLACE_ID="$nid"
    ( IFS= read -r key <&3; [[ -n "$key" && -n "$action" ]] && "$action" "$key" ) &
    exec 3<&-
    rm -f "$fifo"
}

if [[ ! -f "$IMG" ]]; then
    noti -t 5000 --hint string:app_icon:$ERR_ICON "OCR 失败" "图片不存在: $IMG"
    exit 1
fi

if [[ $RETRY -gt 0 ]]; then
    title="OCR 识别中…（第 ${RETRY} 次重试）"
else
    title="OCR 识别中…"
fi
noti "" -t 5000 --hint string:app_icon:$ICON "$title" "$(basename "$IMG")"

err_tmp=$(mktemp)
http_code=$(curl -sS --max-time 10 -o "$RESULT_FILE" -w "%{http_code}" \
    -X POST "$HOST/ocr?model=$MODEL&format=text" \
    -H "X-OCR-Token: $TOKEN" \
    -F "file=@$IMG" 2>"$err_tmp")
curl_rc=$?
curl_err=$(cat "$err_tmp")
rm -f "$err_tmp"

retry_flow() {
    local rest="${1#ocr:}"
    if [[ "$rest" =~ ^([0-9]+):([0-9]+):(.*)$ ]]; then
        exec "$SCRIPT_DIR/ocr_file.sh" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
    elif [[ "$rest" =~ ^([0-9]+):(.*)$ ]]; then
        exec "$SCRIPT_DIR/ocr_file.sh" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
    else
        exec "$SCRIPT_DIR/ocr_file.sh" "$rest"
    fi
}

act_copy() {
    if [[ "$1" == "copy" ]]; then
        xclip -selection clipboard < "$RESULT_FILE"
        cat "$RESULT_FILE" | gpaste-client add 2>/dev/null
        # gdbus call --session --dest org.freedesktop.Notifications \
            # --object-path /org/freedesktop/Notifications \
            # --method org.freedesktop.Notifications.CloseNotification "$REPLACE_ID" >/dev/null 2>&1
    fi
}

act_retry() {
    [[ "$1" == ocr:* ]] && retry_flow "$1"
}

fail() {
    local msg="$1"
    local retry_id=$((REPLACE_ID + 1))
    local next_retry=$((RETRY + 1))
    noti act_retry -t 60000 --hint string:app_icon:$ERR_ICON \
        -A "ocr:${REPLACE_ID:+$retry_id:}$next_retry:$IMG=重试" \
        "OCR 失败" "$msg"
    exit 1
}

if [[ $curl_rc -ne 0 ]]; then
    case "$curl_rc" in
        6)  msg="无法解析主机，请检查网络" ;;
        7)  msg="无法连接 OCR 服务器 $HOST" ;;
        28) msg="请求超时（10s），服务器无响应" ;;
        *)  msg="网络错误（curl $curl_rc）：$(printf '%s' "$curl_err" | head -c 80)" ;;
    esac
    fail "$msg"
fi

case "$http_code" in
    200)
        text=$(python3 -c 'import sys
t = sys.stdin.read().rstrip("\n")
if len(t) > 200:
    t = t[:200] + "…"
sys.stdout.write(t)' < "$RESULT_FILE")
        xclip -selection clipboard < "$RESULT_FILE"
        cat "$RESULT_FILE" | gpaste-client add 2>/dev/null
        cp "$RESULT_FILE" "/tmp/ocr_last_${REPLACE_ID}.txt" 2>/dev/null
        noti -t 5000 --hint string:app_icon:$ICON \
            -A "copy:${REPLACE_ID}=复制" \
            "OCR 结果" "$text"
        ;;
    401) fail "鉴权失败（X-OCR-Token 无效）" ;;
    429) fail "服务繁忙（并发满载），请稍后重试" ;;
    503) fail "服务内存超限，请稍后重试" ;;
    *)   fail "服务返回 HTTP $http_code" ;;
esac
