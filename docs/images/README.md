# Marketing site images

Regenerate the iPhone and iPad shots with `fastlane snapshot`, taking the iPhone 17 Pro Max
and iPad Pro 13-inch captures. `snapshot` covers iOS only: capture the Mac window by hand and
render the first page of an exported report to replace `mac-report.png`.

Downscale to 660px wide, except the hero and the report (900), the iPad shots (1000), and the
Mac window (1200).

`og-card.png` is the social preview. It renders from `og-card.html`, which must be captured at
exactly 1200×630 at a device pixel ratio of 1 — the sizes every card reader expects, and the
ones `index.html` declares.
