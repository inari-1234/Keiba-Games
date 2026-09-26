#!/usr/bin/env python3
"""Bound simulator operations and preserve the exact operation that stalled."""
import datetime
import subprocess
import sys
seconds=int(sys.argv[1])
command=sys.argv[2:]
print(datetime.datetime.now(datetime.timezone.utc).isoformat(), 'START', ' '.join(command), flush=True)
try:
    result=subprocess.run(command,timeout=seconds,check=False)
except subprocess.TimeoutExpired:
    print('TIMEOUT:', ' '.join(command),file=sys.stderr,flush=True)
    raise SystemExit(124)
print(datetime.datetime.now(datetime.timezone.utc).isoformat(), 'END',result.returncode,flush=True)
raise SystemExit(result.returncode)
