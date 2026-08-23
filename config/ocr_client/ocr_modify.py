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
        for k in noti.get("actions", []):
            if isinstance(k, str) and (k.startswith("copy:") or k == "copy"):
                key = k
                break
    if key is None:
        print(json.dumps({"modify": {}, "match": {}}))
        return
    m = re.match(r"^copy(?::(\d+))?$", key)
    if m:
        if m.group(1):
            cmd = "nohup /home/rongzi/.config/ocr_client/ocr_copy.sh %s >/dev/null 2>&1 &" % m.group(1)
        else:
            cmd = "nohup /home/rongzi/.config/ocr_client/ocr_copy.sh >/dev/null 2>&1 &"
        print(json.dumps({"modify": {"action-commands": {key: cmd}}, "match": {}}))
        return
    rest = key[4:]
    m = re.match(r"^(\d+):(\d+):(.*)$", rest)
    if m:
        noti_id, retry, img = m.group(1), m.group(2), m.group(3)
    else:
        m2 = re.match(r"^(\d+):(.*)$", rest)
        if m2:
            noti_id, retry, img = m2.group(1), "", m2.group(2)
        else:
            noti_id, retry, img = "", "", rest
    args = " ".join(shlex.quote(a) for a in (noti_id, retry, img) if a != "")
    cmd = "nohup /home/rongzi/.config/ocr_client/ocr_file.sh %s >/dev/null 2>&1 &" % args
    print(json.dumps({"modify": {"action-commands": {key: cmd}}, "match": {}}))

if __name__ == "__main__":
    main()
