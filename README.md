
# Pizza-Man

[![Build and test](https://github.com/fulldecent/pizzaman/actions/workflows/build-test.yml/badge.svg)](https://github.com/fulldecent/pizzaman/actions/workflows/build-test.yml) [![Lint](https://github.com/fulldecent/pizzaman/actions/workflows/lint.yml/badge.svg)](https://github.com/fulldecent/pizzaman/actions/workflows/lint.yml)

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

```sh
xcodebuild -project "Pizza Man.xcodeproj" -scheme "Pizza Man" -configuration Debug -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" build
```

The app is named because the hero (at center) is a pizza. The things that he is eating are pepperoni.

![Screen Shot](https://user-images.githubusercontent.com/382183/111934259-730f2800-8a97-11eb-93b4-0f8271be7700.jpg)

## Releasing

Use `fix:`, `feat:` or `BREAKING CHANGE:` in commit messages. Release Please opens a pull request from those. `ci:` and `chore:` do not. Merging that pull request submits the iOS app for App Store review. Do not edit [VERSION](VERSION) or the marketing version by hand. Pizza Man does not ship a Mac build.

Every push to `main` runs the tests and uploads an iOS build to TestFlight. It goes to the internal group App Store Connect Users for this app. The Apple ID has to accept the invitation before the build appears. The marketing version comes from [VERSION](VERSION). When that version is already on sale, the upload uses the next patch and does not commit it. The review submission uses the version that was uploaded. The build number is chosen at upload time and is not committed.

Store text lives in [fastlane/metadata](fastlane/metadata). Screenshots are generated at release time and are not committed. What's New is the newest section of [CHANGELOG.md](CHANGELOG.md).

Release Please opens its pull request as `github-actions`. GitHub holds those checks until a person approves the workflow run.

### Setup

1. GitHub repo > Settings > Actions > General > Workflow permissions: Read and write permissions. Check "Allow GitHub Actions to create and approve pull requests".
1. Sign the Apple Developer Program agreement.
1. Repository secrets:

   * `APP_STORE_CONNECT_KEY_ID`
   * `APP_STORE_CONNECT_ISSUER_ID`
   * `APP_STORE_CONNECT_KEY`
   * `APP_STORE_DISTRIBUTION_P12`
   * `APP_STORE_DISTRIBUTION_P12_PASSWORD`

The workflow creates the iOS provisioning profile at build time.

App Privacy, and whether the app uses the Advertising Identifier, stay in App Store Connect. fastlane sends the encryption answer and the third-party content answer.

## References

1. This project is built based on [best practices documented in swift-app-template](https://github.com/fulldecent/swift-app-template), release 1.1.0. The [build-and-test workflow](.github/workflows/build-test.yml), the [lint workflow](.github/workflows/lint.yml), and the [release workflow](.github/workflows/release.yml) are that release's three files. [8 Ball Answer](https://github.com/fulldecent/8-ball-answer) is where the template's upload rules were confirmed. This app ships iOS only. There is no Mac target and no `APP_STORE_MAC_INSTALLER_P12` secret. The template's sample app ships iOS and macOS.
