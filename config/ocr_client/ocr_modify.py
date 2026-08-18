#!/usr/bin/env python3
import json, re, shlex, sys

def main():
    try:
        noti = json.load(sys.stdin)
    except Exception:
        print(json.dumps({"modify": {}, "match": {}}))
        return
    if not isinstance(noti, dict) or not isinstance(noti.get("actions"), list):
        print(json.dumps({"modify": {}, "match": {}}))
        return
    key = None
    for k in noti.get("actions", []):
        if isinstance(k, str) and k.startswith("ocr:"):
            key = k
            break
    if key is None:
        print(json.dumps({"modify": {}, "match": {}}))
        return
    rest = key[4:]
    m = re.match(r"^(\d+):(.*)$", rest)
    if m:
        noti_id, img = m.group(1), m.group(2)
    else:
        noti_id, img = "", rest
    if noti_id:
        args = "%s %s" % (shlex.quote(noti_id), shlex.quote(img))
    else:
        args = shlex.quote(img)
    cmd = "nohup /home/rongzi/.config/ocr_client/ocr_file.sh %s >/dev/null 2>&1 &" % args
    print(json.dumps({"modify": {"action-commands": {key: cmd}}, "match": {}}))

if __name__ == "__main__":
    main()
