fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture the iPhone and iPad stills and render the App Store screenshots

### ios mac_screenshots

```sh
[bundle exec] fastlane ios mac_screenshots
```

Capture the Mac windows and render the Mac App Store screenshots

### ios preview

```sh
[bundle exec] fastlane ios preview
```

Record the App Store preview and render it

### ios creative_assets

```sh
[bundle exec] fastlane ios creative_assets
```

Capture the stills and render the product page header and search result assets

### ios verify

```sh
[bundle exec] fastlane ios verify
```

Check the rendered media against Apple's rules and the screenshots against the storyboard

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload the rendered screenshots to App Store Connect

### ios upload_mac_screenshots

```sh
[bundle exec] fastlane ios upload_mac_screenshots
```

Upload the rendered Mac screenshots to App Store Connect

### ios upload_preview

```sh
[bundle exec] fastlane ios upload_preview
```

Upload the rendered App Store preview to App Store Connect, replacing the ones there

### ios upload_metadata

```sh
[bundle exec] fastlane ios upload_metadata
```

Upload fastlane/metadata to the version open for editing (platform:ios or platform:osx)

### ios download_metadata

```sh
[bundle exec] fastlane ios download_metadata
```

Download the live listing into fastlane/metadata (platform:ios or platform:osx)

### ios screenshots_and_upload

```sh
[bundle exec] fastlane ios screenshots_and_upload
```

Generate screenshots and upload them

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Build and upload to App Store

### ios ci_next_build_number

```sh
[bundle exec] fastlane ios ci_next_build_number
```

Resolve the next build number and write it where CI can read it

### ios ci_release

```sh
[bundle exec] fastlane ios ci_release
```

Archive one platform and upload it to App Store Connect (CI)

### ios ci_verify_release_notes

```sh
[bundle exec] fastlane ios ci_verify_release_notes
```

Refuse to start a release whose notes are missing, empty, or too long (CI)

### ios ci_finish_release

```sh
[bundle exec] fastlane ios ci_finish_release
```

Write the release notes and attach the build to its version (CI)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
