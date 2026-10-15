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
  tvOS validation was pending at that checkpoint; support is now discontinued. See [results](1.1.0/05_RESULTS.md).
- Preserve public source compatibility while introducing improvements.

## 2026-10-15 — Platform Scope
- Discontinue tvOS support and remove its manifest declaration and release gates.
- Keep iOS 13+ as the supported deployment target.
- Evaluate macOS through Mac Catalyst; native AppKit requires a separate port.
- Retain harmless legacy availability annotations; they are not support claims.
- Record build evidence and remaining checks in [platform support](15_PLATFORMS.md).

## 2026-10-15 — Distribution
- Use Swift Package Manager as the sole supported distribution method.
- Remove legacy packaging configuration and its release validation requirements.
