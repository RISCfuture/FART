# frozen_string_literal: true

# Uploads the App Store creative assets `promokit render` writes to fastlane/creative_assets: the
# product page header and search result images and videos, placed on the version open for editing.

CREATIVE_ASSETS_PATH = File.expand_path("creative_assets", __dir__)

# promokit's `creative_assets.json` with each path made absolute, which is exactly what deliver's
# `creative_assets` option takes.
def creative_asset_placements
  listing = File.join(CREATIVE_ASSETS_PATH, "creative_assets.json")
  UI.user_error!("No #{listing}; run the creative_assets lane first.") unless File.exist?(listing)

  JSON.parse(File.read(listing)).map do |entry|
    entry.merge("path" => File.join(CREATIVE_ASSETS_PATH, entry["path"]))
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
