# Roadmap

## Documentation Foundation
- [x] Create refactor/docs-and-agent-guidance from the existing checkout.
- [x] Replace legacy agent guides with one root working agreement.
- [x] Add a root documentation index and focused module scopes.
- [x] Preserve existing compatibility and safety contracts.
- [x] Document pending Fast View improvements separately from current behavior.
- [x] Verify documentation links, structure, and final diff.

## Version 1.1.0 Planning
- [x] Create release/1.1.0 from master and return to the refactor branch.
- [x] Draft [versioned improvement and verification plans](1.1.0/00_INDEX.md).
- [x] Verify the remote release/1.1.0 baseline matches master (c18a229).

## Fast View Reliability — Implemented on Refactor Branch
- [x] Make fluent appearance and layout setters update attached views reliably.
- [x] Separate configuration application from child reconstruction.
- [x] Fix FView reload behavior and remove synthetic lifecycle dispatch.
- [x] Separate inherited modifiers from locally declared modifiers.
- [x] Track and update toolkit-owned constraints without accumulation.
- [x] Add identity-based incremental stack updates.
- [x] Define rebinding and cancellation ownership.
- [x] Add preservation tests and run the full iOS package suite.
- [ ] Run tvOS compilation/runtime validation when its platform is installed.
- [ ] Integrate into release/1.1.0 after release acceptance.

See [the refactor proposal](refactor/01_FAST_VIEW.md) for acceptance checks.
