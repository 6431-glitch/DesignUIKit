# 1.1.0 Verification and Release Acceptance

## Component Preservation
- [x] Changing label text leaves parent and sibling instances unchanged.
- [x] Changing background/opacity works before and after attachment.
- [x] Changing height updates the active constraint without replacing children.
- [x] Repeated configuration does not accumulate constraints or modifiers.
- [x] Reparenting removes obsolete inherited rules and applies the new parent.
- [x] FView reload follows explicit semantics without leaving an empty body.

## Dynamic Children and Bindings
- [x] Same-ID updates reuse instances and call update instead of create.
- [x] Inserts, removals, and reorders affect only their intended children.
- [x] Duplicate IDs follow the documented policy without ambiguous state.
- [x] Retained input views keep first responder, text, and selection state.
- [x] Rebinding follows documented ownership without duplicate delivery.
- [x] Cancelled/deallocated components stop receiving updates and release memory.
- [x] UI changes arrive on the main thread for Combine and Rx integrations.

## Compatibility and Performance
- [x] Existing repository call sites compile without migration.
- [x] Child-controller containment and collection bounds regressions still pass.
- [x] Remove tvOS validation from scope: support discontinued by maintainer decision.
- [x] Measure property update, one-item update, and reorder workloads on a
  recorded simulator/device, OS version, item count, and build configuration.
- [x] Record created/reused view counts and latency before/after each change.
- [x] Property-only workloads create no replacement component views.
- [x] Keyed workloads create views only for inserted identities.

## Release Checklist
- [x] Run all package tests on iOS using [testing](../14_TESTING.md).
- [x] Remove tvOS validation from scope: support discontinued by maintainer decision.
- [x] Record actual test destinations, results, and unresolved verification.
- [x] Document changed setter/reload behavior and binding ownership.
- [x] Update all completed phase checkboxes and root roadmap/status.
- [ ] Review the final release diff and confirm the intended release baseline.
- [ ] Confirm Swift package release metadata against the delivery scope.
- [ ] Obtain release authorization before tagging or publishing artifacts.

## Evidence Boundary
- iOS tests and diagnostic workload measurements passed; see [results](05_RESULTS.md).
- Source findings and proposed fixes are tracked in the [original proposal](../refactor/01_FAST_VIEW.md).
