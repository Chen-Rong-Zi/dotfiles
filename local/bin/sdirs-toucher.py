#!/usr/bin/env python3
"""sdirs-toucher: keep a file's mtime fresh via a held open handle.

Holds an open file descriptor on a target file (default ~/.sdirs) and, at a
configurable interval, updates ONLY the file's mtime to the current time.
Content and atime are left untouched; no other files are accessed.
"""

import argparse
import os
import signal
import sys
import time


def parse_interval(s):
    """Parse an interval like '300', '50ms', '30s', '5m' into seconds."""
    s = s.strip().lower()
    if not s:
        raise argparse.ArgumentTypeError("interval must not be empty")
    if s.endswith("ms"):
        return float(s[:-2]) / 1000.0
    if s.endswith("s"):
        return float(s[:-1])
    if s.endswith("m"):
        return float(s[:-1]) * 60.0
    try:
        return float(s)
    except ValueError:
        raise argparse.ArgumentTypeError(f"invalid interval: {s!r}")


def parse_args(argv):
    p = argparse.ArgumentParser(
        description="Keep a file's mtime fresh via a held file handle."
    )
    p.add_argument("-i", "--interval", type=parse_interval, default=300,
                   help="seconds between mtime updates (default: 300; "
                        "supports suffixes 'ms', 's', 'm', e.g. -i 50ms)")
    p.add_argument("-p", "--path", default="~/.sdirs",
                   help="target file path (default: ~/.sdirs)")
    p.add_argument("-q", "--quiet", action="store_true",
                   help="suppress heartbeat output")
    return p.parse_args(argv)


def open_target(path):
    """Open (creating if needed) the target file; return fd."""
    return os.open(path, os.O_CREAT | os.O_WRONLY, 0o644)


def touch_mtime(fd):
    """Set mtime to now, preserving atime. Returns True on success."""
    try:
        st = os.fstat(fd)
        os.utime(fd, ns=(st.st_atime_ns, time.time_ns()))
        return True
    except OSError as e:
        print(f"sdirs-toucher: utime failed: {e}", file=sys.stderr)
        return False


def main(argv=None):
    args = parse_args(argv)
    path = os.path.expanduser(args.path)

    if args.interval <= 0:
        print("sdirs-toucher: interval must be positive", file=sys.stderr)
        return 2

    try:
        fd = open_target(path)
    except OSError as e:
        print(f"sdirs-toucher: cannot open {path}: {e}", file=sys.stderr)
        return 1

    def _shutdown(signum, frame):
        os.close(fd)
        sys.exit(0)

    signal.signal(signal.SIGTERM, _shutdown)
    signal.signal(signal.SIGINT, _shutdown)

    if not args.quiet:
        print(f"sdirs-toucher: holding {path}, touching mtime every {args.interval}s",
              flush=True)

    last_heartbeat = 0.0
    while True:
        touch_mtime(fd)
        now = time.monotonic()
        if not args.quiet and now - last_heartbeat >= 1.0:
            print(f"sdirs-toucher: tick {time.strftime('%H:%M:%S')}", flush=True)
            last_heartbeat = now
        time.sleep(args.interval)
        # Self-heal: if the path was removed, re-open to keep it alive.
        if not os.path.exists(path):
            try:
                os.close(fd)
                fd = open_target(path)
                print(f"sdirs-toucher: {path} was removed; recreated", file=sys.stderr)
            except OSError as e:
                print(f"sdirs-toucher: cannot recreate {path}: {e}", file=sys.stderr)
                return 1


if __name__ == "__main__":
    sys.exit(main())
