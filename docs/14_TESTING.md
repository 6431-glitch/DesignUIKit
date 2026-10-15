# Validation

## Source Changes
- [ ] Add or update tests in the matching Tests module for changed behavior.
- [ ] Select an available iOS Simulator ID and run:
  `xcodebuild test -scheme DesignUIKit-Package -destination 'platform=iOS Simulator,id=<SIM_ID>'`.
- [ ] For Mac Catalyst evaluation, follow [platform support](15_PLATFORMS.md).
- [ ] Record test results and any platform coverage still pending.

## Test Ownership
| Sources | Tests |
| --- | --- |
| Core | Tests/Core |
| Exts | Tests/Exts |
| ExternalPackages | Tests/External |
| UIKit | Tests/UIKit |
| UIKit+Combine | Tests/UIKitCombine |
| UIKit+Rx | Tests/UIKitRx |

## Host Sanity
- swift test may be useful for host-compatible paths, but UIKit imports can
  prevent host execution; it does not replace simulator validation.
- Do not interpret host build failures as evidence about UIKit runtime behavior.

## Documentation-Only Changes
- [ ] Check every local Markdown link resolves.
- [ ] Keep maintained guidance at 50 lines or fewer per file.
- [ ] Ensure all maintained documents are reachable from docs/00_INDEX.md.
- [ ] Keep only the root AGENTS.md and remove obsolete guide references.
- [ ] Run git diff --check and inspect the final scope.
- [ ] Update roadmap and status with actual results.
