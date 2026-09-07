# Changelog

Release notes for the Flight Assessment of Risk Tool. The version headings are what
`Scripts/release-notes.sh` reads and what the Release workflow writes into App Store Connect's
"What's New" — so a heading is `## <version>`, matching the tag exactly.

Write the entries to survive both renderings. The changelog is read as Markdown here and as plain
text on the store, where the field shows whatever it is given verbatim: a line that only makes
sense with its formatting will read badly in one of the two places.

Versions before 1.4 predate this file; their notes live only on App Store Connect.

## 1.4

- Share your finished assessment as a one-page PDF. A new Share button on the Results screen brings
  the printable FRAT report — until now a Mac-only feature — to iPhone and iPad.

- VoiceOver now reads the results dial as a single instrument, speaking the score together with its
  risk level instead of an unlabeled number followed by "PTS."

- Printing or exporting a report on Mac now tells you when rendering fails instead of doing nothing.
