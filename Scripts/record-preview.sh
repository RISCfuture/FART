#!/bin/bash
# Records the App Store preview on one simulator and edits it to Apple's preview spec.
#
#   Scripts/record-preview.sh [device type] [output file]
#
# PreviewRecording drives the app and lists the stretches of the take worth keeping, scene by
# scene; everything between them (XCUITest finding elements and waiting for the app to idle) is
# cut, so the motion plays at real speed without the dead air. Scripts/edit-preview.sh then frames
# each scene by the storyboard and encodes what App Store Connect takes for iPhone 6.9" and 6.5"
# previews.

set -euo pipefail

readonly DEVICE_TYPE="${1:-iPhone 18 Pro Max}"
readonly OUTPUT="${2:-fastlane/previews/en-US/IPHONE_67-0-risk-loop.mp4}"
REPOSITORY=$(git rev-parse --show-toplevel)
readonly REPOSITORY
readonly SIMULATOR_NAME="claude-${REPOSITORY##*/}-preview"
readonly DERIVED_DATA=".build/DerivedData-preview"
# The cut take and its scenes stay here, so the storyboard can be re-edited without a new take:
#   Scripts/edit-preview.sh .build/preview/take.mp4 .build/preview/scenes <output file>
readonly TAKE_DIRECTORY=".build/preview"
readonly FPS=30

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

# Turns the test's "start end scene" lines into an ffmpeg select expression.
selection() {
  awk '{ printf "%sbetween(t,%s,%s)", (NR > 1 ? "+" : ""), $1, $2 }' "$1"
}

# Places each scene on the cut's timeline, one "scene start end" line each, by adding up the
# lengths of the stretches kept for it. Stretches can overlap, and the cut keeps their shared
# frames once, so each counts only from where the one before it ended.
scene_timeline() {
  awk '
    $3 != scene { if (scene != "") print scene, start, cut; scene = $3; start = cut + 0 }
    { from = ($1 > kept ? $1 : kept); if ($2 > from) cut += $2 - from; if ($2 > kept) kept = $2 }
    END { print scene, start, cut }
  ' "$1"
}

cut_take() {
  local raw="$1" segments="$2" take="$3"
  ffmpeg -nostdin -loglevel error -y -i "$raw" \
    -vf "fps=${FPS},select='$(selection "$segments")',setpts=N/${FPS}/TB,format=yuv420p" \
    -an -c:v libx264 -crf 10 "$take"
}

main() {
  local udid
  udid=$(simulator)
  WORK=$(mktemp -d)
  trap 'stop_recorder; rm -rf "$WORK"' EXIT
  mkdir "$WORK/markers"

  record_take "$udid" "$WORK/markers" "$WORK/raw.mp4"
  mkdir -p "$TAKE_DIRECTORY"
  cut_take "$WORK/raw.mp4" "$WORK/markers/segments" "$TAKE_DIRECTORY/take.mp4"
  cp "$WORK/markers/segments" "$TAKE_DIRECTORY/segments"
  scene_timeline "$TAKE_DIRECTORY/segments" >"$TAKE_DIRECTORY/scenes"
  "$REPOSITORY/Scripts/edit-preview.sh" "$TAKE_DIRECTORY/take.mp4" "$TAKE_DIRECTORY/scenes" "$OUTPUT"
}

main "$@"
