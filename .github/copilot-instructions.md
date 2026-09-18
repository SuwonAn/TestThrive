# Copilot Review Instructions

## Project context
- Platform: iOS app built with SwiftUI.
- Architecture: Clean Architecture (`Domain`, `Data`, `Presentation`).
- Repository pattern: `TaskRepositoryProtocol` with concrete repositories in `Data/Repositories`.

## Review priorities
When reviewing pull requests, focus on:
1. Runtime crashes or force unwrap risks.
2. Regressions in async data loading (`TaskDashboardViewModel`, app startup loading UX).
3. Navigation correctness for `Priority` and `All tasks` item tap flows.
4. State consistency between `isCompleted` UI state and domain model updates.
5. API mapping correctness in `APITaskRepository` (missing fields, fallback handling).
6. Test coverage gaps for changed behavior.

## iOS-specific checks
- Avoid blocking main thread during network/data processing.
- Prefer deterministic `Task`/`async` flows and avoid duplicate fetches.
- Keep SwiftUI view identity stable in `ForEach` and navigation destinations.
- Confirm accessibility labels for interactive controls where needed.

## Style and safety
- Keep changes minimal and scoped.
- Prefer readable names over abbreviations.
- Call out assumptions when backend fields are synthesized.
- Suggest concrete tests for each critical finding.
