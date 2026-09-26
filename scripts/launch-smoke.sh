#!/bin/bash
set -euo pipefail
mkdir -p evidence
xcrun simctl list devices available -j > evidence/devices.json
SIM_ID=$(python3 - <<'PYCODE'
import json
with open('evidence/devices.json') as f:
    data=json.load(f)
phones=[d for r,ds in data['devices'].items() if 'iOS' in r for d in ds if d.get('isAvailable') and d['name'].startswith('iPhone')]
if not phones:
    raise SystemExit('No available iPhone simulator runtime')
phones.sort(key=lambda d: (d['name'] != 'iPhone 15',d['name']))
print(phones[0]['udid'])
PYCODE
)
xcrun simctl boot "$SIM_ID"
xcrun simctl bootstatus "$SIM_ID" -b
xcrun simctl install "$SIM_ID" build/debug/Build/Products/Debug-iphonesimulator/KawaiiRace.app
xcrun simctl launch "$SIM_ID" com.inari.KawaiiRace | tee evidence/launch.txt
sleep 3
xcrun simctl io "$SIM_ID" screenshot evidence/phase1.png
xcrun simctl spawn "$SIM_ID" launchctl list > evidence/processes.txt
if ! grep -F 'com.inari.KawaiiRace' evidence/processes.txt; then
  echo 'App process missing after launch' >&2
  exit 1
fi
xcrun simctl spawn "$SIM_ID" log show --last 2m --style compact --predicate 'process == "KawaiiRace"' > evidence/runtime.log
