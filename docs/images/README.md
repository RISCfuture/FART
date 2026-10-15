# Marketing site images

Regenerate the iPhone and iPad shots with `fastlane screenshots`, taking the
uncaptioned iPhone 18 Pro Max and iPad Pro 13-inch stills it leaves in
`.build/promo/stills/en-US`. `fastlane mac_screenshots` captures the Mac window
into `.build/promo/stills/en-US/mac`. Render the first page of an exported
report to replace `mac-report.png`.

Downscale to 660px wide, except the hero and the report (900), the iPad shots
(1000), and the Mac window (1200).

`og-card.png` is the social preview. It renders from `og-card.html`, which must
be captured at exactly 1200×630 at a device pixel ratio of 1 — the sizes every
card reader expects, and the ones `index.html` declares.
