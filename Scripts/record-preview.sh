#!/bin/bash
# Records the App Store preview on one simulator and converts it to Apple's preview spec.
#
#   Scripts/record-preview.sh [device type] [output file]
#
# PreviewRecording drives the app and lists the stretches of the take worth keeping; everything
# between them (XCUITest finding elements and waiting for the app to idle) is cut, so the motion
# plays at real speed without the dead air. The result is 886×1920 H.264 at 30 fps with a silent
# stereo AAC track, which is what App Store Connect takes for iPhone 6.9" and 6.5" previews. Every
# frame is a keyframe: a mostly still screen otherwise compresses well below the 10 Mbps App Store
# Connect asks for.

set -euo pipefail

readonly DEVICE_TYPE="${1:-iPhone 18 Pro Max}"
readonly OUTPUT="${2:-fastlane/previews/en-US/IPHONE_67-0-risk-loop.mp4}"
REPOSITORY=$(git rev-parse --show-toplevel)
readonly REPOSITORY
readonly SIMULATOR_NAME="claude-${REPOSITORY##*/}-preview"
readonly DERIVED_DATA=".build/DerivedData-preview"
readonly WIDTH=886 HEIGHT=1920 FPS=30
readonly MIN_SECONDS=15 MAX_SECONDS=30

simulator() {
  local udid
  udid=$(xcrun simctl list -j devices available |
    jq -r --arg n "$SIMULATOR_NAME" '[.devices[][] | select(.name == $n)][0].udid // empty')
  [[ -n "$udid" ]] || udid=$(xcrun simctl create "$SIMULATOR_NAME" "$DEVICE_TYPE")
  xcrun simctl bootstatus "$udid" -b >/dev/null
  xcrun simctl status_bar "$udid" override --time 9:41 --batteryState charged --batteryLevel 100 \
    --cellularBars 4 --wifiBars 3
  echo "$udid"
}

stop_recorder() {
  [[ -n "${RECORDER_PID:-}" ]] || return 0
  kill -INT "$RECORDER_PID" 2>/dev/null || true
  wait "$RECORDER_PID" 2>/dev/null || true
  RECORDER_PID=""
}

wait_for() {
  local marker="$1"
  until [[ -e "$marker" ]]; do
    kill -0 "$TEST_PID" 2>/dev/null || { echo "The test ended before $marker appeared" >&2; exit 1; }
    sleep 0.1
  done
}

wait_for_line() {
  local pattern="$1" file="$2"
  until grep -q "$pattern" "$file" 2>/dev/null; do sleep 0.05; done
}

record_take() {
  local udid="$1" markers="$2" raw="$3"
  xcodebuild build-for-testing -project "Flight Assessment of Risk Tool.xcodeproj" \
    -scheme "Generate Screenshots" -destination "id=$udid" -derivedDataPath "$DERIVED_DATA" \
    -quiet

  TEST_RUNNER_PREVIEW_MARKER_DIRECTORY="$markers" xcodebuild test-without-building \
    -project "Flight Assessment of Risk Tool.xcodeproj" -scheme "Generate Screenshots" \
    -destination "id=$udid" -derivedDataPath "$DERIVED_DATA" \
    -only-testing "Generate Screenshots/PreviewRecording/testRecordPreview" -quiet &
  TEST_PID=$!

  wait_for "$markers/ready"
  xcrun simctl io "$udid" recordVideo --codec=h264 --force "$raw" 2>"$markers/recorder.log" &
  RECORDER_PID=$!
  wait_for_line "Recording started" "$markers/recorder.log"
  touch "$markers/recording"

  wait_for "$markers/segments"
  stop_recorder
  wait "$TEST_PID"
}

# Turns the test's "start end" lines into an ffmpeg select expression.
selection() {
  awk '{ printf "%sbetween(t,%s,%s)", (NR > 1 ? "+" : ""), $1, $2 }' "$1"
}

convert() {
  local raw="$1" segments="$2"
  mkdir -p "$(dirname "$OUTPUT")"
  ffmpeg -loglevel error -y -i "$raw" \
    -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100" \
    -vf "fps=${FPS},select='$(selection "$segments")',setpts=N/${FPS}/TB,scale=${WIDTH}:${HEIGHT}:force_original_aspect_ratio=increase,crop=${WIDTH}:${HEIGHT},format=yuv420p" \
    -c:v libx264 -profile:v high -level:v 4.0 -g 1 -b:v 11M -minrate 10M -maxrate 12M -bufsize 12M \
    -c:a aac -b:a 256k -shortest -movflags +faststart "$OUTPUT"
}

check_length() {
  local seconds
  seconds=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$OUTPUT")
  echo "$OUTPUT: ${seconds}s"
  if (($(echo "$seconds < $MIN_SECONDS || $seconds > $MAX_SECONDS" | bc))); then
    echo "Outside App Store Connect's ${MIN_SECONDS}–${MAX_SECONDS}s range — retime the test." >&2
    exit 1
  fi
}

main() {
  local udid
  udid=$(simulator)
  WORK=$(mktemp -d)
  trap 'stop_recorder; rm -rf "$WORK"' EXIT
  mkdir "$WORK/markers"

  record_take "$udid" "$WORK/markers" "$WORK/raw.mp4"
  convert "$WORK/raw.mp4" "$WORK/markers/segments"
  check_length
}

main "$@"
