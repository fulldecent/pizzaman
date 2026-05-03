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

### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```

Bump the marketing version. Pass bump:patch (default), bump:minor, or bump:major

### ios bump_build

```sh
[bundle exec] fastlane ios bump_build
```

Bump only the build number (used before each beta upload)

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate App Store screenshots

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload local screenshots to the editable App Store version

### ios screenshots_and_upload

```sh
[bundle exec] fastlane ios screenshots_and_upload
```

Generate screenshots and upload them to App Store Connect

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build a signed release .ipa, upload it to TestFlight, then bump the build number for next time

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build the signed release .ipa without uploading (for testing the build pipeline)

### ios release

```sh
[bundle exec] fastlane ios release
```

Full App Store release: capture screenshots, attach the latest TestFlight build, submit for review

### ios submit_only

```sh
[bundle exec] fastlane ios submit_only
```

Recover from a failed release: update release notes on the latest version, drop any orphan draft submission, then create and submit a fresh one

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
