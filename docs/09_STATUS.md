# Project Status

## Current Work
- Date: 2026-10-15; branch: refactor/docs-and-agent-guidance.
- Version 1.1.0 phases 1–4 are implemented and validated on iOS.
- Documentation is being committed separately for release/1.1.0.
- Implementation is still uncommitted; phase commits will live on refactor/main.

## Completed
- [x] Replace legacy agent guides with one root agreement and indexed module docs.
- [x] Create and push release/1.1.0 from master; verify remote baseline c18a229.
- [x] Return to the refactor branch with documentation changes preserved.
- [x] Phase 1: explicit content operations, body reload fix, selective setters.
- [x] Phase 2: inherited modifier restoration, owned constraints, layer updates.
- [x] Phase 3: keyed stack reconciliation and opt-in Combine/Rx adapters.
- [x] Phase 4: named binding ownership/cancellation and consumer documentation.
- [x] Update obsolete collection-section tests to the current API.
- [x] Pass all 89 package tests on iPhone 17 Pro, iOS 26.5.
- [x] Measure property, single-item, and reorder allocation/timing workloads.

## Verification and Release Boundary
- [Results](1.1.0/05_RESULTS.md) records environment, counts, and measurement limits.
- [ ] Run tvOS compilation/runtime tests; the tvOS platform is not installed.
- [ ] Complete [release acceptance](1.1.0/02_VERIFICATION.md), including metadata.
- [ ] Integrate validated changes into release/1.1.0.
- The release branch currently points to master baseline c18a229; docs merge is next.
