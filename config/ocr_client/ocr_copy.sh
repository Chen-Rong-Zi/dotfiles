#!/bin/bash
RESULT_FILE="${OCR_RESULT_FILE:-/tmp/ocr_last.txt}"

if [[ "${1:-}" =~ ^[0-9]+$ ]]; then
    HISTORY="/tmp/ocr_last_${1}.txt"
    [[ -f "$HISTORY" ]] && RESULT_FILE="$HISTORY"
fi

[[ -f "$RESULT_FILE" ]] || exit 1

xclip -selection clipboard < "$RESULT_FILE"
cat "$RESULT_FILE" | gpaste-client add 2>/dev/null
