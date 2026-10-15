# Platform Support

## Policy
- iOS 13+ is supported across all six library products.
- tvOS support is discontinued by maintainer decision on 2026-10-15.
- Mac Catalyst builds and automated tests pass; manual validation is pending.
- Native macOS/AppKit is unsupported: UIKit imports exist even in DesignCore.
- Do not add `.macOS(...)` to imply UIKit compatibility with AppKit.
- Omitting tvOS from SwiftPM's platform list does not prohibit consumers from
  attempting a build; supported scope is the policy above.

## Validation Checklist
- [x] Remove tvOS from Package.swift and maintained release requirements.
- [x] Build all library modules for Mac Catalyst (arm64, Xcode 26.6).
- [x] Attempt package tests on Mac Catalyst; host setup blocks responder coverage.
- [x] Add a Catalyst app test host; all 52 UIKit tests passed on this Mac.
- [ ] Perform a consumer interaction smoke test.
- [ ] Verify window resizing, keyboard/focus, menus, scrolling, and containment.
- [x] Re-run the iOS regression suite: all 107 package tests passed.

## Reproduction
```sh
xcodebuild build -scheme DesignUIKit-Package \
  -destination 'generic/platform=macOS,variant=Mac Catalyst' \
  -disableAutomaticPackageResolution CODE_SIGNING_ALLOWED=NO
```

## Evidence
- All six products compiled for Mac Catalyst; runtime support remains provisional.
- Initial unhosted responder failure is addressed by the [app host](16_CATALYST_TESTS.md).
- Current Mac: arm64, macOS 26.5.1, Xcode 26.6 (2026-10-15).
- Final package run passed: 106 tests passed, one window test explicitly skipped.
- Hosted UIKit run: all 52 tests passed, including the window/responder test.
- iOS regression: 107 tests passed on iPhone 17 Pro, iOS 26.5.
- See [release acceptance](1.1.0/02_VERIFICATION.md) for distribution checks.

## Current-Mac Test Command
```sh
xcodebuild test -scheme DesignUIKit-Package \
  -destination 'platform=macOS,variant=Mac Catalyst,arch=arm64' \
  -disableAutomaticPackageResolution CODE_SIGNING_ALLOWED=NO
```
