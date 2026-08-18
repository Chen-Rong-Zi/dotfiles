#!/bin/bash
RESULT_FILE="${OCR_RESULT_FILE:-/tmp/ocr_last.txt}"

[[ -f "$RESULT_FILE" ]] || exit 1

xclip -selection clipboard < "$RESULT_FILE"
cat "$RESULT_FILE" | gpaste-client add 2>/dev/null