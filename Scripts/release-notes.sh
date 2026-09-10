#!/bin/bash
#
# release-notes.sh — shared release-notes renderer, revision 5 (2026-09-09).
# Copies live in seven app repositories; a copy that does not say revision 5 is stale.
#
# Prints one version's section of CHANGELOG.md, for whatever wants the release notes.
#
#   Scripts/release-notes.sh [--plain] <version> [locale]
#
# `--plain` feeds App Store Connect's "What's New". Where the release also reaches users outside
# the store, the Markdown form feeds `gh release create --notes-file`. One source for every
# destination, so the changelog, the store and a GitHub release cannot drift into describing the
# same build differently.
#
# `--plain` renders the section as App Store Connect wants it: no Markdown, since that field shows
# the text verbatim, and no hard wrapping, since it reflows to whatever width the reader's App Store
# is. Headings become plain lines, bullets become "•", and inline code loses its backticks. Skip
# this rendering and the Markdown ships as-is: a listing reading "# WHAT'S NEW", hash included, is
# what an unrendered heading looks like on the store, and it cannot be fixed without a new version.
#
# LOCALES. A translated app gives a locale its own heading at the same level as the version —
# `## 1.2 de-DE` beside `## 1.2` — and asking for that locale selects it. Locales sit at the version
# level rather than nesting under it so that `###` stays free for category headings like `### New`,
# and so selecting a section stays one exact string match rather than a rule about which headings
# are locales. A locale with no section of its own falls back to the plain version section, so a
# newly added territory reads the default text rather than nothing.
#
# The `## <version>` heading itself is dropped: App Store Connect has no use for it.

set -euo pipefail

plain=false
if [ "${1:-}" = "--plain" ]; then
  plain=true
  shift
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "usage: $(basename "$0") [--plain] <version> [locale]" >&2
  exit 2
fi

version="$1"
locale="${2:-}"
changelog="$(dirname "$0")/../CHANGELOG.md"

if [ ! -f "$changelog" ]; then
  echo "No changelog at $changelog." >&2
  exit 1
fi

# `-v version=` rather than interpolating: a version string is data, and awk would otherwise parse
# whatever it contains. Matching is on the whole line so "1.1" cannot select the "1.10" section.
section() {
  awk -v heading="## $1" '
    $0 == heading { collecting = 1; next }
    collecting && /^## / { exit }
    collecting { print }
  ' "$changelog"
}

notes=""
[ -n "$locale" ] && notes=$(section "$version $locale")
[ -z "$notes" ] && notes=$(section "$version")

# Trim the blank lines the section is bracketed by, then refuse an empty one. A release whose notes
# silently came out empty is worse than one that fails here: the notes are what a reader uses to
# decide whether to update, and by upload time the tag is already spent.
notes=$(printf '%s\n' "$notes" | sed -e '/./,$!d' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

if [ -z "$notes" ]; then
  echo "CHANGELOG.md has no \"## $version\" section. Add one before tagging $version." >&2
  exit 1
fi

if [ "$plain" = false ]; then
  printf '%s\n' "$notes"
  exit 0
fi

# Unwrapping is why this is awk and not a sed pipeline: a bullet spans however many lines the
# 100-column source needed, and joining them is a decision about the *previous* line, which a
# line-at-a-time filter cannot make without holding one back.
printf '%s\n' "$notes" | awk '
  # A blank line in the source is a paragraph break and has to survive as one: the store renders
  # this verbatim, so prose that loses its breaks arrives as a single block. `separate` carries a
  # pending break to the next thing emitted, which is why consecutive bullets stay consecutive —
  # nothing sets it between them — while paragraphs and headings keep their air.
  function emit(line) {
    if (separate && printed) print ""
    separate = 0
    print line
    printed = 1
  }
  function flush() { if (buffer != "") { emit(buffer); buffer = "" } }
  { gsub(/`/, "") }
  # `separate` is set on both sides: a heading is given air beneath it whether or not the source
  # left a blank line there. Deriving that from the source alone would make the spacing depend on
  # the author remembering, and a heading flush against its first bullet is the one rendering this
  # was changed to stop producing.
  /^#+ / { flush(); sub(/^#+ /, ""); separate = 1; emit($0); separate = 1; next }
  /^[-*] / { flush(); sub(/^[-*] /, "• "); buffer = $0; next }
  /^[[:space:]]*$/ { flush(); separate = 1; next }
  { sub(/^[[:space:]]+/, ""); buffer = (buffer == "" ? $0 : buffer " " $0) }
  END { flush() }
' | sed -e '/./,$!d'
