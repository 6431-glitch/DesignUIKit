# Third Improvement Plan: Ease of Use

## Goal and State
- Started 2026-10-15 on refactor/main after the second improvement pass.
- Help a UIKit developer install, compose, update, and diagnose a screen predictably.
- Preserve existing signatures and Bool/callback behavior; diagnostics are opt-in.
- These branch APIs are unreleased; examples must identify their source version.

## Phase U1 — Onboarding
- [x] Add a user-facing documentation index and installation/module guidance.
- [x] Provide a complete first-screen example with its imports and hosting context.
- [x] Explain the base module and optional Combine/Rx products.
- [x] Add binding and keyed-stack introductions with explicit closure types.

## Phase U2 — Practical Cookbook
- [ ] Add focused form, loading-state, dynamic-list, controller, and layout recipes.
- [ ] Show retained view instances and selective updates in each relevant recipe.
- [ ] Explain when custom layout requires disabling automatic parent attachment.
- [ ] Typecheck user-guide Swift examples against the actual built package modules.

## Phase U3 — Predictable Update Guidance
- [ ] Add a decision table for mutate, bind, updateItems, updateContent, and reload.
- [ ] Explain immediate appearance versus deferred/coalesced layout changes.
- [ ] Document component-specific reload behavior and FView's one-time construction.
- [ ] Clarify named versus unkeyed binding lifetime and modifier precedence.

## Phase U4 — Actionable Diagnostics
- [ ] Add a structured keyed-update Result API alongside the existing Bool API.
- [ ] Report duplicate-ID and reused-view positions with actionable messages.
- [ ] Add typed reactive error callbacks while preserving existing callbacks.
- [ ] Add opt-in configuration diagnostics for fixed sizes with pinned parent edges.
- [ ] Document diagnostic limits and test rejection without partial updates.

## Acceptance Checklist
- [x] Draft and index the third improvement plan before implementation.
- [ ] Link the full onboarding/cookbook/update/diagnostic path from README.
- [ ] Typecheck all user-guide Swift examples, excluding package-manifest fragments.
- [ ] Pass new diagnostic checks and the existing iOS package suite.
- [ ] Validate tvOS when its platform destination is available.
- [ ] Keep each maintained guidance file at 50 lines or fewer and validate links.
- [ ] Commit each phase with updated progress and validation evidence.

## Boundaries
- UIKit composition and selective updates remain the model.
- Release packaging, CI upgrades, and large-reorder optimization are separate work.
- Configuration diagnostics describe known rule combinations, not the full Auto Layout solver.
