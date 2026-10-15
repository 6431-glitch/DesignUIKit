# Project Status

## Current Work
- Date: 2026-10-15; branch: refactor/main.
- All three improvement passes are implemented and iOS-validated.
- Documentation commit 00912ec is merged locally into release/1.1.0.

## First and Second Passes
- [x] Initial phases 1–4: selective updates, stable configuration, keyed stacks, bindings.
- [x] Quality phases A–D: named snapshots, focused layout, coherent state, naming.
- Evidence: [first-pass](1.1.0/05_RESULTS.md) and [quality results](1.1.0/07_CODE_QUALITY_RESULTS.md).

## Third-Pass Delivery
- [x] U1: onboarding and first-screen/binding/keyed-content guides (cb3b72e).
- [x] U2: five practical cookbook recipes (fcfc19d).
- [x] U3: update decisions, timing, lifecycle, and ownership (c2926b6).
- [x] U4: structured update errors, typed callbacks, and opt-in layout diagnostics.
- [Plan](1.1.0/08_USABILITY_IMPROVEMENTS.md), [results](1.1.0/09_USABILITY_RESULTS.md), and [user guides](usage/00_INDEX.md).

## Validation
- All 107 package tests passed on iPhone 17 Pro, iOS 26.5.
- All 11 user-guide Swift examples independently typechecked for iOS 13+.
- Two package-manifest fragments excluded from standalone example compilation.
- Existing Bool/callback signatures remain; structured diagnostics are additive.
- Documentation links, index coverage, and 50-line limits passed.

## Platform Scope
- [x] Discontinue tvOS and update the manifest and maintained requirements.
- [x] Build all products for Mac Catalyst; iOS regression passed all 107 tests.
- [x] Catalyst package: 106 passed, one host-dependent test explicitly skipped.
- [x] Catalyst app host: all 52 UIKit tests passed, including responder/selection.
- [ ] Complete manual Catalyst interaction checks.
- See [platform support](15_PLATFORMS.md) for evidence and remaining checks.

## Distribution
- [x] Keep Swift Package Manager as the sole supported distribution method.
- [x] Remove legacy packaging files, ignore rules, and documentation references.

## Remaining Release Gates
- [x] Remove tvOS validation from scope: support discontinued by maintainer decision.
- [ ] Complete [release acceptance](1.1.0/02_VERIFICATION.md), including metadata.
- [x] Prepare refactor/main for review into release/1.1.0; CI remains unchanged.
- [ ] Integrate implementation commits into release/1.1.0.
- Release contains documentation only; its remote remains at baseline c18a229.
