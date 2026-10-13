# fastlane

`ship_testflight` uploads iOS. `generate_screenshots` draws the store images. `upload_screenshots` sends those images without review. `submit_app_store` sends the uploaded build to review. The GitHub workflow in `.github/workflows/release.yml` runs these lanes.
