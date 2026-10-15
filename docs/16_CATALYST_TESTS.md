# Mac Catalyst Hosted Tests

## Why a Host Exists
- A plain package test process has no application lifecycle for native windows.
- `Tests/CatalystHost` provides a UIKit application and a hosted test target.
- The hosted target compiles the existing `Tests/UIKit` sources unchanged.
- Add new UIKit test files to this project's test target as well as the package.
- Only the window-dependent responder test skips in unhosted Catalyst runs;
  it runs all identity, first-responder, text, and selection assertions in the host.
- iOS package runs continue to execute that test without a skip.

## Run on This Mac
```sh
xcodebuild test -project Tests/CatalystHost/CatalystHost.xcodeproj \
  -scheme CatalystHost \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  -disableAutomaticPackageResolution CODE_SIGNING_ALLOWED=NO
```
- The host uses a local reference to the repository package.
- Keep the host's resolved dependencies aligned with root Package.resolved.
- Run the package scheme separately for Core, Exts, External, Combine, and Rx.

## Verification
- [x] Add a real application lifecycle without changing library behavior.
- [x] Retain all responder and selection assertions in the hosted test.
- [x] Hosted Catalyst: 52 tests passed, zero skips.
- [x] Package Catalyst: 106 passed, one explicit skip covered by the host.
- [x] iOS regression: all 107 tests passed, including responder/selection.
- Manual resizing, keyboard interaction, and menu checks remain separate from tests.
