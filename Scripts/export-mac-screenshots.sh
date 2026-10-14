#!/bin/bash
# Pulls the window captures that MacScreenshots attached to a result bundle and composes each onto
# a 2880×1800 (16:10) canvas tinted with the risk band it shows, as the Mac App Store expects.
#
#   Scripts/export-mac-screenshots.sh <result bundle> [output directory]
#
# The output directory defaults to fastlane/screenshots_mac/en-US.

set -euo pipefail

readonly CANVAS="2880x1800"
readonly WINDOW_BOUNDS="2560x1520>"
readonly LOW_WASH="#eef5ea"
readonly MODERATE_WASH="#fbf7e8"
readonly HIGH_WASH="#faf0ef"

usage() {
  echo "usage: $0 <result bundle> [output directory]" >&2
  exit 64
}

wash_for() {
  case "$1" in
    *moderate*) echo "$MODERATE_WASH" ;;
    *high*) echo "$HIGH_WASH" ;;
    *) echo "$LOW_WASH" ;;
  esac
}

compose() {
  local window="$1" name="$2" output="$3"
  magick -quiet -size "$CANVAS" "xc:$(wash_for "$name")" \
    \( "$window" -resize "$WINDOW_BOUNDS" \
       \( +clone -background "#1a1712" -shadow 28x36+0+24 \) +swap \
       -background none -layers merge +repage \) \
    -gravity center -composite -alpha off "$output/$name.png"
}

main() {
  [[ $# -ge 1 ]] || usage
  local bundle="$1"
  local output="${2:-fastlane/screenshots_mac/en-US}"
  STAGING="$(mktemp -d)"
  trap 'rm -rf "$STAGING"' EXIT

  xcrun xcresulttool export attachments --path "$bundle" --output-path "$STAGING" >/dev/null
  mkdir -p "$output"

  local exported name
  while IFS=$'\t' read -r exported name; do
    compose "$STAGING/$exported" "$name" "$output"
    echo "$output/$name.png"
  done < <(jq -r '.[].attachments[]
                  | select(.suggestedHumanReadableName | test("^[0-9]+-"))
                  | [.exportedFileName, (.suggestedHumanReadableName | sub("_[0-9]+_[0-9A-F-]+\\.png$"; ""))]
                  | @tsv' "$STAGING/manifest.json")
}

main "$@"
