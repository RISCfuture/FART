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
# A window's corner radius in a Retina capture (16 pt at 2×). The capture is the window's bounding
# rectangle, so whatever sits behind the rounded corners comes with it until they are cut away,
# along with the outermost pixel, which blends the window's edge into the desktop.
readonly CORNER_RADIUS=32
readonly EDGE=1

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

# Cuts the capture to the window's own rounded shape.
round_corners() {
  local window="$1" rounded="$2" width height
  read -r width height < <(magick -quiet "$window" -shave "${EDGE}x${EDGE}" -format '%w %h\n' info:)
  magick -quiet "$window" -shave "${EDGE}x${EDGE}" -alpha set \
    \( -size "${width}x${height}" xc:none -fill white \
       -draw "roundrectangle 0,0,$((width - 1)),$((height - 1)),$CORNER_RADIUS,$CORNER_RADIUS" \) \
    -compose DstIn -composite "$rounded"
}

compose() {
  local window="$1" name="$2" output="$3"
  round_corners "$window" "$STAGING/$name-rounded.png"
  magick -quiet -size "$CANVAS" "xc:$(wash_for "$name")" \
    \( "$STAGING/$name-rounded.png" -resize "$WINDOW_BOUNDS" \
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
