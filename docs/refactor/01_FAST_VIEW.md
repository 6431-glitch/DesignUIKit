# Fast View Selective-Update Proposal

## State
- Implemented in the [1.1.0 phases](../1.1.0/00_INDEX.md); iOS validated on 2026-10-15.
- Goal: update affected properties or children while retaining unchanged views.
- Preserve existing public API compatibility during implementation.

## Priority 1 — Consistent Updates
- [x] Make appearance setters apply to attached views immediately.
- [x] Invalidate only affected constraints for frame/padding/position changes.
- [x] Separate appearance, layout, and structure operations.
- [x] Replace reload's synthetic didMoveToSuperview dispatch with explicit work.
- [x] Fix FView reload removing its body while hasConfiguredViews stays true.

## Priority 2 — Stable Configuration
- [x] Separate local modifiers from inherited modifiers during reparenting.
- [x] Define whether modifiers mutate views or may return replacements.
- [x] Track toolkit-owned constraints and prevent duplicate installation.
- [x] Define sizing precedence for parent edges and stack-managed children.
- [x] Define binding replacement and cancellation ownership.

## Priority 3 — Incremental Children
- [x] Add a stable-ID stack API with distinct create and update closures.
- [x] Insert/remove/move only affected children and retain unchanged instances.
- [x] Keep the existing stack binding source-compatible.

## Acceptance Checks
- [x] A label update preserves parent and sibling identities.
- [x] A height update preserves child views and updates the active constraint.
- [x] Reload has explicit, tested semantics for FView and container components.
- [x] Reparenting does not accumulate inherited modifiers or constraints.
- [x] Stack updates preserve focused input and state of unchanged children.
- [x] Rebinding does not cause duplicate deliveries or retained views.
- [x] Matching tests pass on the iOS simulator.
- [x] Remove tvOS validation from scope: support discontinued by maintainer decision.

## Source Evidence
- [Configuration setters](../../Sources/UIKit/SwiftUIKit/Base/Exts/FConfigurable+.swift).
- [Configuration application](../../Sources/UIKit/SwiftUIKit/Base/FConfigurable.swift).
- [Reload](../../Sources/UIKit/SwiftUIKit/Base/FComponent.swift) and [FView](../../Sources/UIKit/SwiftUIKit/Base/FView.swift).
- [Rx stack binding](../../Sources/UIKit+Rx/View/FStack+Rx.swift).
