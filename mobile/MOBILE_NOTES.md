# Mobile App Notes

## Architecture Decisions
- State management: Riverpod with ChangeNotifier controllers for auth, app data, settings, tutorial, and simulation state.
- Data layer: Hybrid strategy.
  - Remote-first via Dio against existing Nest endpoints.
  - Local fallback via shared_preferences caches for projects, tasks, users, sprints, token/session, theme, and tutorial state.
- Business model parity: Dart models mirror backend schemas for User, Project, Task, Sprint, and EventLog.
- Simulation engine: Deterministic local engine implemented in Dart for mobile-only simulation controls.

## Web to Flutter Mapping
- Landing/auth:
  - React: frontend/src/app/login/page.tsx, frontend/src/app/register/page.tsx
  - Flutter: lib/screens/login_screen.dart, lib/screens/register_screen.dart
- Dashboard:
  - React: frontend/src/app/dashboard/page.tsx
  - Flutter: lib/screens/dashboard_screen.dart
- Projects list:
  - React: frontend/src/app/dashboard/projects/page.tsx
  - Flutter: lib/screens/projects_screen.dart
- Project backlog:
  - React: frontend/src/app/dashboard/projects/[id]/page.tsx
  - Flutter: lib/screens/project_detail_screen.dart
- Sprint board:
  - React: frontend/src/app/dashboard/sprints/[id]/page.tsx
  - Flutter: lib/screens/sprint_screen.dart
- Team management:
  - React: frontend/src/app/dashboard/team/page.tsx
  - Flutter: lib/screens/team_screen.dart
- Achievements:
  - React: frontend/src/app/dashboard/achievements/page.tsx
  - Flutter: lib/screens/achievements_screen.dart
- Settings/profile:
  - React: frontend/src/app/dashboard/settings/page.tsx
  - Flutter: lib/screens/settings_screen.dart
- Leaderboard:
  - React: frontend/src/app/leaderboard/page.tsx
  - Flutter: lib/screens/leaderboard_screen.dart

## Simulation Logic Notes
- React web sprint page currently contains placeholder simulation comments and alert-only day advance.
- Dart implementation in lib/providers/simulation_engine.dart provides real controls for:
  - play, pause, step day
  - velocity impact events
  - task progression TODO -> IN_PROGRESS -> REVIEW -> DONE
  - burndown remaining points
  - end-of-sprint metrics summary
- Inline comment in SimulationEngine.stepDay references web sprint board intent to keep behavior auditable.

## UI Adaptations for Mobile
- Sidebar nav converted to bottom NavigationBar.
- Hover interactions removed; replaced with tap targets and card/list patterns.
- Added touch-friendly controls and full-width action buttons for forms.
- Added first-run tutorial flow (mobile-only) because web has no onboarding.

## Feature Parity Checklist
- [x] Sprint setup / configuration
- [x] Backlog creation and story management
- [x] Sprint simulation execution and controls (play, pause, step)
- [x] Velocity and burndown tracking
- [x] End-of-sprint summary / scoring / metrics
- [x] Onboarding / tutorial flow (mobile-first addition)
- [x] Persistent state (shared_preferences for session + caches)

## Testing
- Widget tests added:
  - test/sprint_screen_test.dart
  - test/project_detail_screen_test.dart
- Simulation unit tests added:
  - test/simulation_engine_test.dart

## Known Constraints in This Environment
- Flutter SDK was not available in this execution environment, so flutter create could not be run.
- android/ and ios/ folders are present as placeholders; run flutter create . inside /mobile on a machine with Flutter installed to generate full platform scaffolding.
