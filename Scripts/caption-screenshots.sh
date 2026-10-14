#!/bin/bash
# Sets a caption above every screenshot in a folder, writing <name>_framed.png beside each capture.
# deliver uploads the _framed versions in place of the raw ones whenever they exist.
#
#   Scripts/caption-screenshots.sh <screenshot folder>...
#
# Captions come from fastlane/captions/<locale>.json, keyed by the part of the file name after its
# number ("questions" in "iPhone 18 Pro-1-questions.png"); the locale is the folder's name. Each
# frame renders from fastlane/captions/frame.html in Chrome at the capture's exact size.

set -euo pipefail

readonly CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
REPOSITORY=$(git rev-parse --show-toplevel)
readonly REPOSITORY
readonly FRAME="$REPOSITORY/fastlane/captions/frame.html"

usage() {
  echo "usage: $0 <screenshot folder>..." >&2
  exit 64
}

shot_of() {
  local file="${1##*/}"
  [[ "${file%.png}" =~ [0-9]+-([a-z-]+)$ ]] && echo "${BASH_REMATCH[1]}"
}

band_of() {
  case "$1" in
    *moderate*) echo moderate ;;
    *high*) echo high ;;
    *) echo low ;;
  esac
}

layout_of() {
  local width="$1" height="$2"
  if ((width > height)); then
    echo mac
  elif ((height * 10 / width > 15)); then
    echo phone
  else
    echo tablet
  fi
}

url_encode() {
  jq -rn --arg value "$1" '$value | @uri'
}

caption() {
  local capture="$1" captions="$2"
  local shot width height layout query output
  shot=$(shot_of "$capture")
  read -r width height < <(magick -quiet "$capture" -format '%w %h\n' info:)
  layout=$(layout_of "$width" "$height")

  local text
  text=$(jq -r --arg shot "$shot" '.[$shot] // empty' "$captions")
  if [[ -z "$text" ]]; then
    echo "No caption for \"$shot\" in $captions" >&2
    exit 1
  fi

  query="image=$(url_encode "file://$capture")&caption=$(url_encode "$text")"
  query+="&band=$(band_of "$shot")&layout=$layout"

  output="${capture%.png}_framed.png"
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
    --allow-file-access-from-files --window-size="$width,$height" --virtual-time-budget=3000 \
    --screenshot="$output" "file://$FRAME?$query" 2>/dev/null
  magick -quiet "$output" -alpha off "$output"
  echo "$output"
}

main() {
  [[ $# -ge 1 ]] || usage
  local folder capture captions
  for folder in "$@"; do
    folder=$(cd "$folder" && pwd)
    captions="$REPOSITORY/fastlane/captions/${folder##*/}.json"
    [[ -f "$captions" ]] || { echo "No captions at $captions" >&2; exit 1; }
    for capture in "$folder"/*.png; do
      [[ "$capture" == *_framed.png ]] && continue
      caption "$capture" "$captions"
    done
  done
}

main "$@"
