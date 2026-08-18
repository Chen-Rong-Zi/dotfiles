#!/usr/bin/env python3
import json, sys

def shell_quote(s):
    return "'" + s.replace("'", "'\\''") + "'"

def main():
    try:
        noti = json.load(sys.stdin)
    except Exception:
        print(json.dumps({"modify": {}, "match": {}}))
        return
    actions = noti.get("actions", [])
    key = None
    for k in actions:
        if isinstance(k, str) and k.startswith("ocr:"):
            key = k
            break
    if key is None:
        print(json.dumps({"modify": {}, "match": {}}))
        return
    img = key[4:]
    cmd = "/bin/bash -c 'exec nohup /home/rongzi/.config/ocr_client/ocr_file.sh %s >/dev/null 2>&1 &'" % shell_quote(img)
    print(json.dumps({"modify": {"action-commands": {key: cmd}}, "match": {}}))

if __name__ == "__main__":
    main()
