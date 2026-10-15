# Second Improvement Pass: Validation

## Environment
- Branch: refactor/main; date: 2026-10-15.
- iPhone 17 Pro, iOS 26.5; Xcode 26.6 (17F113), Debug, arm64 Simulator.
- Destination: 4FFBF522-1DE8-4306-B5C8-E89F786D5E78.
- Use the package command in [testing](../14_TESTING.md), with
  -disableAutomaticPackageResolution for the existing resolved dependency graph.

## Phase A
- [x] Replace closure factories with named snapshots and an explicit lifecycle.
- [x] Pass 39 UIKit tests, including three new modifier behavior/lifetime checks.
- Preserve the existing theme-key matching and restoration policy.
- Built-in styles are toolkit-restored; custom modifier cleanup remains caller-owned.

## Remaining Validation
- [ ] Phase B: typed layout keys and constraint topology preservation.
- [ ] Phase C: coherent keyed state and larger reorder measurements.
- [ ] Phase D: naming audit, final full suite, and documentation review.
- [ ] tvOS: install its platform before compilation/runtime verification.

## Scope
- Public signatures and observable update contracts remain the compatibility boundary.
- [First-pass evidence](05_RESULTS.md) remains separate from these refactor results.
