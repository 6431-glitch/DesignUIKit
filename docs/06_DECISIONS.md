# Decision Log

## 2026-10-15 — Documentation Organization
- Adopt SeamlessReader's working-agreement headings, metadata, numbered index,
  focused documents, and checkbox-based progress tracking.
- Adapt its app-oriented guidance to this reusable Swift package.
- Replace the seven old agent guides with a single root AGENTS.md.
- Centralize module contracts in docs/modules rather than nested agent files.
- Keep maintained guidance at 50 lines or fewer per file.
- Do not copy app redesign branches, app commands, or feature-specific rules.

## 2026-10-15 — Selective Updates
- The intended Fast View direction is to update only affected components.
- Property changes should retain the existing view and its siblings.
- Structural updates should preserve unchanged child instances by stable ID.
- Phases 1–4 are now implemented on the refactor branch and validated on iOS;
  tvOS validation remains pending. See [results](1.1.0/05_RESULTS.md).
- Preserve public source compatibility while introducing improvements.
