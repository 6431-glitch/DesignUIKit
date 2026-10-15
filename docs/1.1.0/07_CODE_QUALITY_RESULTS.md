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

## Phase B
- [x] Pass 42 UIKit tests, including three new layout compatibility checks.
- Typed keys preserve existing debug identifiers and constant-only constraint reuse.
- Parent, priority, and existing center-axis behavior remain covered.

## Phase C
- [x] Pass all 99 package tests; add manual-reset, invalid-reuse, and model-type checks.
- Model snapshots and views now share one entry; casts stay inside keyed state.
- Four reversals, Debug Simulator sample; no replacement views or update callbacks:
| Rows | Before state refactor | After state refactor |
| --- | --- | --- |
| 100 | 6.55 ms | 6.68 ms |
| 500 | 113.63 ms | 117.44 ms |
| 1,000 | 455.26 ms | 464.52 ms |
- Single samples are diagnostic; no speedup is claimed and no algorithm changed.
- Large hierarchy reorders remain a separate potential optimization.

## Phase D
- [x] Pass all 99 package tests after normalizing internal pending/applied-state names.
- Public signatures and consumer update/binding contracts remain unchanged.
- Existing property/single-item/reorder workloads still create no replacement views.

## Remaining Validation
- [x] Phase B: typed layout keys and constraint topology preservation.
- [x] Phase C: coherent keyed state and larger reorder measurements.
- [x] Phase D: naming audit, final full suite, and documentation review.
- [x] Remove tvOS validation from scope: support discontinued by maintainer decision.

## Scope
- Public signatures and observable update contracts remain the compatibility boundary.
- [First-pass evidence](05_RESULTS.md) remains separate from these refactor results.
