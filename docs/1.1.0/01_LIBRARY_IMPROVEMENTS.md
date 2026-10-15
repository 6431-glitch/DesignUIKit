# 1.1.0 Library Improvement Plan

## Goal and Scope
- Improve Fast View reliability and selective updates; phase commits are on refactor/main.
- Retain existing UIKit instances for property-only changes.
- Preserve public APIs; add explicit APIs where existing semantics must remain.
- Maintain module boundaries in [architecture](../11_ARCHITECTURE.md).

## Phase 1 — Define and Repair Update Behavior
- [x] Reproduce FView reload removing its body and lock in a regression test.
- [x] Introduce explicit appearance/layout/content update operations.
- [x] Remove internal reliance on manually invoking UIKit lifecycle callbacks.
- [x] Make background/opacity setters update attached views immediately.
- [x] Make frame/padding/position changes update only relevant constraints.
- [x] Coalesce repeated layout invalidations without rebuilding children.

## Phase 2 — Stable Configuration and Layout
- [x] Separate locally declared modifiers from inherited parent modifiers.
- [x] Recompute inherited styles on reparenting without accumulating modifiers.
- [x] Define modifier mutation/replacement semantics and test the chosen contract.
- [x] Track toolkit-owned constraints; update constants or replace affected rules.
- [x] Define priority rules for explicit sizing, parent edges, and stack layout.
- [x] Audit shape/shadow changes and avoid redundant work during layout.

## Phase 3 — Incremental Dynamic Content
- [x] Add keyed stack updates with stable IDs and create/update closures.
- [x] Create only inserted views, detach removed views, and move retained views.
- [x] Define duplicate-ID handling before exposing the API.
- [x] Preserve focused input, local state, and subscriptions for retained IDs.
- [x] Add opt-in Combine/Rx adapters while keeping existing bindings compatible.

## Phase 4 — Binding Lifetime and Consumer Guidance
- [ ] Define append versus replace semantics for repeated binding calls.
- [ ] Provide scoped cancellation without clearing unrelated subscriptions.
- [ ] Keep UI delivery on the main thread and avoid strong view captures.
- [ ] Document setter timing, update scope, and binding ownership with examples.
- [ ] Correct README module/dependency/requirements tables against Package.swift.

## Delivery Rules
- [x] Deliver phases in order with matching tests and documentation updates.
- [x] Update [version progress](00_INDEX.md) and [status](../09_STATUS.md) per milestone.
- [x] Keep Core/Exts/External changes limited to evidence-backed supporting work.
- [x] Defer breaking API redesigns and dependency upgrades to separate proposals.
- [ ] Complete [verification](02_VERIFICATION.md) before release integration.
