# DesignUIKit AI Working Agreement

## Metadata
- Owner: DesignUIKit maintainers
- Last Reviewed: 2026-10-15
- Layer: System
## Scope
- Applies repository-wide; module contracts live in `docs/modules/`.
- This is the single agent entry point; do not add nested AGENTS files.

## Current User Story
- As a toolkit consumer, I want composable UIKit components and selective updates with stable public APIs.

## Acceptance Criteria
- [ ] Preserve module boundaries and documented compatibility contracts.
- [ ] Keep maintained documentation reachable from [documentation index](docs/00_INDEX.md).
- [ ] Verify changes and update progress before completing a task.

## Required Workflow
- [ ] Read [documentation index](docs/00_INDEX.md) and the relevant module scope before editing.
- [ ] For source changes, read `docs/11_ARCHITECTURE.md` and `docs/12_DEPENDENCIES.md`.
- [ ] Inspect existing implementation and tests; preserve unrelated changes.
- [ ] Use Markdown checkboxes for plans, tasks, and acceptance criteria.
- [ ] Update relevant docs and `docs/09_STATUS.md` as work progresses.
- [ ] Validate the changed behavior or documents and review the final diff.

## Out of Scope
- Feature/domain business logic and new use of excluded `Archived/` APIs.

## Implementation Boundaries
- Keep reactive integrations in DesignCombineUIKit and DesignRxUIKit.
- Keep concrete use cases in consumer feature/domain modules and inject them.
- Prefer extensions or new types over changing established core semantics.

## Do Not Break
- Public source compatibility unless a breaking change is explicitly requested.
- iOS/tvOS support, child-controller containment, and collection bounds safety.
- Module-specific contracts recorded in [module scopes](docs/modules/00_INDEX.md).

## Documentation Rules
- Maintained guidance covers one concern per file and stays at 50 lines or fewer.
- Distinguish implemented behavior, proposals, and verification still pending.

## Validation
- Follow [validation guide](docs/14_TESTING.md); add matching module tests for behavior changes.
- Documentation-only work requires link, scope, and diff checks.

## Precedence
1. Explicit user instructions take precedence.
2. Root architecture constraints govern module scope documents.
