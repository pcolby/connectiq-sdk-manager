# Changelog

## [0.6.5][] (2025-09-27)

Added Connect IQ SDK v8.3.0 ([71a29ba][]).

## [0.6.4][] (2025-08-13)

Added Connect IQ SDK v8.2.3 ([4d3fd0e][]).

## [0.6.3][] (2025-07-19)

Added Connect IQ SDK v8.2.2 ([fcffa42][]).

## [0.6.2][] (2025-06-21)

Bumped Connect IQ SDK Manager to v1.0.15 ([8d6d465][]), and added Connect IQ SDK v8.2.1 ([c0aa0bc][]).

Note, also removed Connect IQ SDK v8.2.0, as Garmin has dropped it from their manifest ([`sdks.json`][]).

## [0.6.1][] (2025-06-18)

Added Connect IQ SDK v8.2.0.

## [0.6.0][] (2025-05-25)

Updated `install.sh` to only install the latest `simulator` and `monkeymotion` versions that match installed SDK's
major version/s.

Now releasing all available SDK versions for those that need specific, non-latest versions.

## [0.5.0][] (2025-05-24)

Added a custom linuxdeploy plugin to modifiy the `libwebkit2gtk` library to no longer need a symlink.

The packaged AppImage/s no longer have any `root` user prerequisites.

## [0.4.0][] (2025-05-23)

Added a basic `install.sh` script to download and install the latest release assets.

## [0.3.0][] (2025-05-10)

Bumped the Connect IQ SDK to v8.1.1 ([433ef16][]), and added a [continuous][] release.

## [0.2.0][] (2025-03-08)

Added Bash script to build AppImages for the `simulator` and `monkeymotion` binaries within the Connect IQ SDKs, along
with the SDK manager itself.

## [0.1.0][] (2025-02-18)

Initial release to generate a single AppImage for the latest Connect IQ SDK Manager.

[0.6.5]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.6.5
[0.6.4]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.6.4
[0.6.3]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.6.3
[0.6.2]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.6.2
[0.6.1]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.6.1
[0.6.0]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.6.0
[0.5.0]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.5.0
[0.4.0]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.4.0
[0.3.0]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.3.0
[0.2.0]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.2.0
[0.1.0]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/v0.1.0

[433ef16]: https://github.com/pcolby/connectiq-sdk-manager/commit/433ef1699dc39e531ad10efc6d3e761ad9d11bd4
[4d3fd0e]: https://github.com/pcolby/connectiq-sdk-manager/commit/4d3fd0ebc338c048c92b9b9f66c79dff752275d0
[71a29ba]: https://github.com/pcolby/connectiq-sdk-manager/commit/71a29ba7968ef00d60c0dec336739bd7300dd734
[8d6d465]: https://github.com/pcolby/connectiq-sdk-manager/commit/8d6d46529cc9b8ca2c395eccb41ad1bd910d3413
[c0aa0bc]: https://github.com/pcolby/connectiq-sdk-manager/commit/c0aa0bc6a5e4334e195475226a805c23797cd091
[fcffa42]: https://github.com/pcolby/connectiq-sdk-manager/commit/fcffa42d8ab5ed1bd3c4244f75fa60978ba1f3ef

[continuous]: https://github.com/pcolby/connectiq-sdk-manager/releases/tag/continuous
[`sdks.json`]: https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
