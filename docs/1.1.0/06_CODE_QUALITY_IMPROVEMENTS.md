# Second Improvement Plan: Code Quality and Readability

## State and Goal
- Draft dated 2026-10-15, after first-pass phases 1–4 were committed on refactor/main.
- First-pass validation: 89 iOS tests passed; tvOS remains unverified.
- Goal: make update behavior easier to trace while preserving public signatures,
  unchanged view identity, constraint reuse, and subscription ownership.
- Phases A–B are implemented and iOS-validated on refactor/main.

## Phase A — Named Modifier Snapshots
- [x] Replace the nested (() -> () -> Void)? restoration factory with a named type.
- [x] Make capture-original, capture-applied, and conditional-restore steps explicit.
- [x] Share the inherited/local application loop without hiding their precedence.
- [x] Document built-in restoration versus custom modifier cleanup ownership.
- [x] Cover direct overrides, theme changes, removal, and repeated reparenting.

## Phase B — Focused Layout Operations
- [x] Replace string constraint identifiers in internal storage with a key enum.
- [x] Split applyLayout into parent transition, desired rules, reconciliation,
  and custom-constraint handling, with one clear responsibility per helper.
- [x] Name the constraint-topology comparison instead of inlining it in the loop.
- [x] Preserve active constraint identity when only constants change.
- [x] Clarify existing FAxis-to-center-anchor mapping without breaking callers.

## Phase C — Explicit Keyed Collection State
- [ ] Replace parallel view/model dictionaries with one coherent entry/state type.
- [ ] Isolate Any/AnyHashable casts at a documented internal boundary.
- [ ] Remove reliance on assignment clearing state followed by manual restoration.
- [ ] Separate ID validation, create/update decisions, and hierarchy reconciliation.
- [ ] Preserve duplicate rejection, equal-value skipping, focus, and selection.
- [ ] Profile larger keyed reorders before changing the reconciliation algorithm.

## Phase D — Naming and Handoff
- [ ] Use consistent names for stored state, pending work, and cancellation slots.
- [ ] Keep original public APIs and add no unnecessary abstraction layers.
- [ ] Update consumer docs only when an observable contract changes.
- [ ] Deliver and validate each phase as a focused commit with progress updates.

## Acceptance Checklist
- [x] Draft and index the second improvement plan.
- [x] Remove nested restoration factories and magic string layout keys.
- [ ] Make keyed state ownership understandable from one type or entry point.
- [ ] Pass existing regressions and add tests only for uncovered behavior.
- [ ] Record workload counts/timings and verify no new replacement-view allocations.
- [ ] Validate iOS and tvOS; retain explicit limits where platform support is absent.
- [ ] Review the final diff for source compatibility and update status/results.

## References
- [Modifier restoration](../../Sources/UIKit/SwiftUIKit/Base/Exts/FConfiguration+Modifiers.swift), [layout](../../Sources/UIKit/SwiftUIKit/Base/Exts/FConfiguration+Layout.swift), and [keyed items](../../Sources/UIKit/SwiftUIKit/Common/Components/Collection/FStack+Items.swift).
