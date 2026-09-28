#!/bin/bash
set -euo pipefail
SIM_ID=$(cat evidence/simulator-id)
CONTROL_APP=build/KeibaRuntimeControl.app
mkdir -p "$CONTROL_APP"
SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
SIM_ARCH=$(uname -m)
xcrun swiftc -parse-as-library scripts/runtime-control.swift -sdk "$SDK_PATH" -target "$SIM_ARCH-apple-ios17.0-simulator" -o "$CONTROL_APP/KeibaRuntimeControl"
python3 - <<'PY'
import plistlib
from pathlib import Path
p=Path('build/KeibaRuntimeControl.app/Info.plist')
p.write_bytes(plistlib.dumps({'CFBundleIdentifier':'com.inari.KeibaRuntimeControl','CFBundleName':'KeibaRuntimeControl','CFBundleExecutable':'KeibaRuntimeControl','CFBundlePackageType':'APPL','CFBundleVersion':'1','CFBundleShortVersionString':'1.0','MinimumOSVersion':'17.0','UIDeviceFamily':[1],'UILaunchScreen':{}}))
PY
codesign --force --sign - "$CONTROL_APP"
python3 scripts/bounded-command.py 90 xcrun simctl install "$SIM_ID" "$CONTROL_APP"
