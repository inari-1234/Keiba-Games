#!/bin/bash
set -euo pipefail
SIM_ID=$(cat evidence/simulator-id)
swiftc scripts/compress-video.swift -o build/compress-video
record_screen() {
  local screen=$1
  local duration=$2
  xcrun simctl io "$SIM_ID" recordVideo --codec=h264 "evidence/$screen-raw.mov" > "evidence/$screen-video.log" 2>&1 &
  local recorder=$!
  sleep 2
  python3 scripts/bounded-command.py 60 xcrun simctl launch --terminate-running-process "$SIM_ID" com.inari.KawaiiRace "--$screen"
  if [ "$duration" -gt 45 ]; then
    sleep 40
    python3 scripts/bounded-command.py 60 xcrun simctl io "$SIM_ID" screenshot "evidence/$screen-midpoint.png"
    sleep "$((duration - 40))"
  else
    sleep "$duration"
  fi
  kill -INT "$recorder"
  wait "$recorder"
  python3 scripts/bounded-command.py 120 build/compress-video "evidence/$screen-raw.mov" "evidence/$screen.mp4"
  test -s "evidence/$screen.mp4"
  rm "evidence/$screen-raw.mov"
}
record_screen paddock 8
record_screen race 80
python3 scripts/bounded-command.py 60 xcrun simctl io "$SIM_ID" screenshot evidence/normal-race-finished.png
python3 scripts/bounded-command.py 60 xcrun simctl spawn "$SIM_ID" log show --last 20m --style json --predicate 'process == "KawaiiRace" AND (messageType == error OR messageType == fault)' > evidence/runtime-errors.json
