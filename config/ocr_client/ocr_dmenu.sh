#!/bin/bash
ITEMS=$(cat)

KEY=$(printf '%s' "$ITEMS" | grep -oP '\[\d+,\K[^\]]+' | head -1)
NID=$(printf '%s' "$ITEMS" | grep -oP '\[\K\d+' | head -1)
close_notify() { dunstctl close "$NID" >/dev/null 2>&1; }

case "$KEY" in
    ocr:*)
        IMG="${KEY#ocr:}"
        close_notify
        nohup /home/rongzi/.config/ocr_client/ocr_file.sh "$IMG" >/dev/null 2>&1 &
        exit 0
        ;;
    copy)
        close_notify
        nohup /home/rongzi/.config/ocr_client/ocr_copy.sh >/dev/null 2>&1 &
        exit 0
        ;;
esac

printf '%s\n' "$ITEMS" | /usr/bin/dmenu "$@"