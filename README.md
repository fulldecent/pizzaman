
# Pizza-Man

Get in on the App Store: <https://apps.apple.com/us/app/pizza-man/id931174800>

The iOS game

Devour this devilishly difficult diversion.

This game takes place in the future where man has left the planet and only pizza remains!

Help this 7-slice plain pizza pie indulge in incoming pepperoni pieces.

You will become immortal (in real life) if you reach level 100.

* Email <englishmajor@phor.net> if you're able to add additional alliteration above

---

## Development

### Requirements

* Xcode 15.0+

* iOS 15.0+
* Swift 5.9+

### Building

This project uses modern iOS development practices and can be built using Xcode or the command line:

```bash
xcodebuild -project "Pizza Man.xcodeproj" -scheme "Pizza Man" -configuration Debug -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" build
```

### Continuous integration

The project includes GitHub Actions CI that automatically builds and tests the app on every push and pull request.

### Releasing a new version

The release process uses [fastlane](https://fastlane.tools). See [fastlane/README.md](fastlane/README.md) for one-time setup (Ruby, the App Store Connect API key at `fastlane/api_key.json`).

The pipeline has three stages, run as separate lanes:

```plain
bump_version  →  beta (TestFlight)  →  release (App Store)
```

1. Bump the marketing version (`CFBundleShortVersionString`) and build number:

   ```bash
   bundle exec fastlane bump_version           # patch (default): 4.0.1 → 4.0.2
   bundle exec fastlane bump_version bump:minor
   bundle exec fastlane bump_version bump:major
   ```

   Then update `app_version` in [fastlane/Deliverfile](fastlane/Deliverfile) to match the new version. Commit the version bump.

2. Build, sign, and ship to TestFlight. This bumps the build number, archives, exports, and uploads:

   ```bash
   bundle exec fastlane beta
   ```

   Test the build on a real device via TestFlight.

3. Submit to the App Store. This captures screenshots, uploads them to the editable version, attaches the most recent TestFlight build, and submits for review with auto-release on approval. You'll be prompted for the release notes ("What's New" in en-US), or you can pass them inline:

   ```bash
   bundle exec fastlane release
   bundle exec fastlane release notes:"Update game center"
   ```

Run individual steps if you only need part of the flow:

```bash
bundle exec fastlane screenshots            # capture only, no upload
bundle exec fastlane upload_screenshots     # upload existing screenshots
bundle exec fastlane screenshots_and_upload # capture + upload, no review submit
```

Screenshots are written to `fastlane/screenshots/` and built artifacts to `build/`. Both are gitignored.

#### Note: rsync workaround

The `before_all` hook in [fastlane/Fastfile](fastlane/Fastfile) strips `/opt/homebrew` and `/usr/local` from `PATH` before `xcodebuild -exportArchive` runs. Without this, Xcode 26's IPA packaging step fails with `Copy failed` because `/usr/bin/rsync` (openrsync 2.6.9) and Homebrew's `rsync` 3.x interpret the `-E` flag differently. Sanitizing `PATH` ensures both ends use openrsync.

---

The app is named because the hero (at center) is a pizza. The things that he is eating are pepperoni.

![Screen Shot](https://user-images.githubusercontent.com/382183/111934259-730f2800-8a97-11eb-93b4-0f8271be7700.jpg)
