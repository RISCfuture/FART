#!/bin/bash
# Cuts a recorded take into the App Store preview: each scene punches in on its subject, flies its
# caption in word by word, and whip-pans into the next.
#
#   Scripts/edit-preview.sh <take> <scenes> <output>
#
# <scenes> lists the take's scenes in order, one "name start end" line each, in seconds. The
# storyboard, fastlane/captions/preview.<locale>.json with the locale taken from the output's
# folder, can give each scene:
#
#   zoom     {to, y, at}: the scale to punch in to, the height to punch in on (a fraction of the
#            frame), and how many seconds into the scene the punch lands
#   caption  the line to fly in, and position: top, middle (the default) or bottom
#   whip     left or right: the way the scene pans in from the one before it
#
# Captions render frame by frame from fastlane/captions/title.html in Chrome. The result is
# 886×1920 H.264 at 30 fps with a silent stereo AAC track, every frame a keyframe to hold the
# 10 Mbps App Store Connect asks for.

set -euo pipefail

readonly CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
REPOSITORY=$(git rev-parse --show-toplevel)
readonly REPOSITORY
readonly TITLE="$REPOSITORY/fastlane/captions/title.html"
readonly WIDTH=886 HEIGHT=1920 FPS=30
readonly MIN_SECONDS=15 MAX_SECONDS=30
# A punch-in eases out fast and holds. It stays centred across the frame's width, so neither side
# edge pins to the frame while the other is still moving, and scales straight from the take's
# full resolution so a deep punch stays sharp.
readonly PUNCH=0.4
readonly WHIP=0.2 WHIP_BLUR=90
# A caption flies in once the whip into its scene has landed, over a band of the frame tall
# enough for three lines; the entrance runs as long as title.html takes to settle every word.
readonly CAPTION_HEIGHT=440 CAPTION_DELAY=0.15 CAPTION_ENTRANCE=0.9
readonly CAPTION_TOP=140 CAPTION_MIDDLE=860 CAPTION_BOTTOM=1330
readonly RENDERERS=6
# A scene opens on a tab switch, which changes most of the screen; a switch flip barely scores.
readonly SWITCH_SCORE=5 SWITCH_SEARCH_BEFORE=1.5 SWITCH_SEARCH_LENGTH=3.5

usage() {
  echo "usage: $0 <take> <scenes> <output>" >&2
  exit 64
}

# Evaluates an arithmetic expression, printed with a leading zero as ffmpeg expects.
calculate() {
  printf '%.4f' "$(echo "$1" | bc -l)"
}

url_encode() {
  jq -rn --arg value "$1" '$value | @uri'
}

seconds_of() {
  ffprobe -v error -show_entries format=duration -of csv=p=0 "$1"
}

# Prints a storyboard entry's field for a scene, or nothing when it has none.
board() {
  local scene="$1" path="$2"
  jq -r --arg scene "$scene" ".[] | select(.scene == \$scene) | $path // empty" "$STORYBOARD"
}

# MARK: - Scene boundaries

# Prints the time of the tab switch nearest a scene's estimated start, or the estimate when the
# footage around it holds no switch.
switch_near() {
  local take="$1" estimate="$2"
  local from
  from=$(calculate "if ($estimate > $SWITCH_SEARCH_BEFORE) $estimate - $SWITCH_SEARCH_BEFORE else 0")
  ffmpeg -nostdin -hide_banner -ss "$from" -t "$SWITCH_SEARCH_LENGTH" -i "$take" \
    -vf "scdet=threshold=$SWITCH_SCORE,metadata=print:key=lavfi.scd.score:file=-" -f null - \
    2>/dev/null |
    paste -d ' ' - - |
    awk -v from="$from" -v estimate="$estimate" -v least="$SWITCH_SCORE" '
      { split($3, time, ":"); split($4, score, "=") }
      score[2] > best && score[2] > least { best = score[2]; at = from + time[2] }
      END { printf "%.4f\n", (best ? at : estimate) }
    '
}

# Moves every scene boundary after the first onto the tab switch that opens the next scene, so no
# scene carries a moment of the screen before it. The recorder runs a little behind the test's
# clock, which leaves the estimated boundaries early.
snap_scenes() {
  local take="$1" scenes="$2"
  local names=() starts=() scene start end index
  while read -r scene start end; do
    names+=("$scene")
    if ((${#starts[@]} == 0)); then
      starts+=("$start")
    else
      starts+=("$(switch_near "$take" "$start")")
    fi
  done <"$scenes"
  starts+=("$(seconds_of "$take")")
  for ((index = 0; index < ${#names[@]}; index++)); do
    echo "${names[index]} ${starts[index]} ${starts[index + 1]}"
  done
}

# MARK: - Captions

caption_top() {
  case "$1" in
    top) echo "$CAPTION_TOP" ;;
    bottom) echo "$CAPTION_BOTTOM" ;;
    *) echo "$CAPTION_MIDDLE" ;;
  esac
}

# Renders a caption's entrance as numbered frames in a directory of its own, several at a time.
render_caption() {
  local caption="$1" directory="$2"
  local frames frame
  frames=$(calculate "$CAPTION_ENTRANCE * $FPS")
  mkdir -p "$directory"
  for ((frame = 0; frame <= ${frames%.*}; frame++)); do
    printf -- '--screenshot=%s/%04d.png\n' "$directory" "$frame"
    printf 'file://%s?caption=%s&t=%s\n' "$TITLE" "$(url_encode "$caption")" \
      "$(calculate "$frame / $FPS")"
  done | xargs -n 2 -P "$RENDERERS" "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 --default-background-color=00000000 \
    --window-size="$WIDTH,$CAPTION_HEIGHT" --virtual-time-budget=2000 2>/dev/null
}

# MARK: - Scenes

# An expression for the zoom at time t: an ease-out from full frame to the punch, landing `at`
# seconds into the scene.
zoom_expression() {
  local to="$1" at="$2"
  local progress="clip((t-$at)/$PUNCH,0,1)"
  echo "(1+($to-1)*(1-pow(1-$progress,3)))"
}

framing_filter() {
  local scene="$1" start="$2" end="$3"
  local to at y zoom
  to=$(board "$scene" .zoom.to)
  at=$(board "$scene" .zoom.at)
  y=$(board "$scene" .zoom.y)
  zoom=$(zoom_expression "${to:-1}" "${at:-0}")

  local zoomed_width="2*trunc($WIDTH*$zoom/2)" zoomed_height="2*trunc($HEIGHT*$zoom/2)"

  # crop reads its input's size once, so the offsets come from the zoom itself.
  printf '%s' "trim=start=$start:end=$end,setpts=PTS-STARTPTS,fps=$FPS," \
    "crop=iw:'2*trunc(iw*$HEIGHT/$WIDTH/2)'," \
    "scale=w='$zoomed_width':h='$zoomed_height':eval=frame:flags=lanczos," \
    "crop=$WIDTH:$HEIGHT:x='($zoomed_width-$WIDTH)/2':y='($zoomed_height-$HEIGHT)*${y:-0.5}'," \
    "setsar=1"
}

render_scene() {
  local take="$1" scene="$2" start="$3" end="$4" output="$5"
  local caption framing top
  caption=$(board "$scene" .caption)
  framing=$(framing_filter "$scene" "$start" "$end")

  if [[ -z "$caption" ]]; then
    ffmpeg -nostdin -loglevel error -y -i "$take" -vf "$framing" \
      -an -c:v libx264 -crf 10 -pix_fmt yuv420p "$output"
    return
  fi

  render_caption "$caption" "$WORK/$scene-caption"
  top=$(caption_top "$(board "$scene" .position)")
  ffmpeg -nostdin -loglevel error -y -i "$take" \
    -framerate "$FPS" -i "$WORK/$scene-caption/%04d.png" \
    -filter_complex "[0:v]${framing}[framed];[1:v]setpts=PTS+$CAPTION_DELAY/TB[caption];
      [framed][caption]overlay=x=0:y=$top:eof_action=repeat" \
    -an -c:v libx264 -crf 10 -pix_fmt yuv420p "$output"
}

# MARK: - Assembly

# Chains the scenes with whip pans, each starting one whip before the footage so far runs out,
# and blurs the frame along the pan while it moves.
whip_filter() {
  local clips=("$@")
  local filter="" blur="" previous="[0:v]" length offset index whip
  length=$(seconds_of "${clips[0]}")
  for ((index = 1; index < ${#clips[@]}; index++)); do
    offset=$(calculate "$length - $WHIP")
    whip=$(board "$(scene_of "${clips[index]}")" .whip)
    filter+="${previous}[$index:v]xfade=transition=slide${whip:-left}:duration=$WHIP"
    filter+=":offset=${offset}[v$index];"
    blur+="${blur:+,}dblur=angle=0:radius=$WHIP_BLUR"
    blur+=":enable='between(t,$offset,$(calculate "$offset + $WHIP"))'"
    previous="[v$index]"
    length=$(calculate "$offset + $(seconds_of "${clips[index]}")")
  done
  printf '%s' "${filter}${previous}${blur:+$blur,}format=yuv420p[video]"
}

# Recovers a scene's name from its clip, named "<index>-<scene>.mp4".
scene_of() {
  local name
  name=$(basename "$1" .mp4)
  echo "${name#*-}"
}

assemble() {
  local output="$1"
  shift
  local inputs=() clip
  for clip in "$@"; do inputs+=(-i "$clip"); done
  mkdir -p "$(dirname "$output")"
  ffmpeg -nostdin -loglevel error -y "${inputs[@]}" \
    -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=44100" \
    -filter_complex "$(whip_filter "$@")" -map "[video]" -map "$#:a" \
    -c:v libx264 -profile:v high -level:v 4.0 -r "$FPS" -g 1 \
    -b:v 11M -minrate 10M -maxrate 12M -bufsize 12M \
    -c:a aac -b:a 256k -shortest -movflags +faststart "$output"
}

check_length() {
  local output="$1" seconds
  seconds=$(seconds_of "$output")
  echo "$output: ${seconds}s"
  if (($(echo "$seconds < $MIN_SECONDS || $seconds > $MAX_SECONDS" | bc))); then
    echo "Outside App Store Connect's ${MIN_SECONDS}–${MAX_SECONDS}s range — retime the test." >&2
    exit 1
  fi
}

main() {
  [[ $# -eq 3 ]] || usage
  local take="$1" scenes="$2" output="$3"
  local locale
  locale=$(basename "$(dirname "$output")")
  STORYBOARD="$REPOSITORY/fastlane/captions/preview.$locale.json"
  [[ -f "$STORYBOARD" ]] || { echo "No storyboard at $STORYBOARD" >&2; exit 1; }
  WORK=$(mktemp -d)
  trap 'rm -rf "$WORK"' EXIT

  snap_scenes "$take" "$scenes" >"$WORK/scenes"
  local clips=() scene start end
  while read -r scene start end; do
    render_scene "$take" "$scene" "$start" "$end" "$WORK/${#clips[@]}-$scene.mp4"
    clips+=("$WORK/${#clips[@]}-$scene.mp4")
  done <"$WORK/scenes"

  assemble "$output" "${clips[@]}"
  check_length "$output"
}

main "$@"
