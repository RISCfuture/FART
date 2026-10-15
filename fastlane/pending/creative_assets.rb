# frozen_string_literal: true

# Uploads the App Store creative assets `promokit render` writes to fastlane/creative_assets.
#
# Written against deliver's `creative_assets` and `overwrite_creative_assets` options, which
# fastlane PR #30442 (https://github.com/fastlane/fastlane/pull/30442) adds and no fastlane release
# has yet. Once a release carries them, add `import "pending/creative_assets.rb"` to the Fastfile.
#
# Each placement needs its App Store Connect placement group, read from the environment as
# ASC_PRODUCT_PAGE_HEADER_ASSET_GROUP and ASC_APP_STORE_SEARCH_RESULTS_ASSET_GROUP.

CREATIVE_ASSETS_PATH = File.expand_path("../creative_assets", __dir__)

# promokit's `creative_assets.json`, with each path made absolute and its placement group added.
def creative_asset_placements
  listing = File.join(CREATIVE_ASSETS_PATH, "creative_assets.json")
  UI.user_error!("No #{listing}; run the creative_assets lane first.") unless File.exist?(listing)

  JSON.parse(File.read(listing)).map do |entry|
    entry.merge("path"            => File.join(CREATIVE_ASSETS_PATH, entry["path"]),
                "placement_group" => ENV.fetch("ASC_#{entry["placement_type"]}_GROUP"))
  end
end

platform :ios do
  desc "Upload the rendered creative assets to App Store Connect, replacing the ones there"
  lane :upload_creative_assets do
    placements = creative_asset_placements
    verify
    ensure_api_key
    upload_to_app_store(
      app_identifier:             APP_IDENTIFIER,
      creative_assets:            placements,
      overwrite_creative_assets:  true,
      skip_binary_upload:         true,
      skip_metadata:              true,
      skip_screenshots:           true,
      force:                      true,
      run_precheck_before_submit: false
    )
  end
end
