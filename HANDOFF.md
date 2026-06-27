# Handoff — Next Session

## Git State
- **HEAD:** `a269d84` fix: #80 PropertyGrid onSave typed, remove try/catch fallback, update tests
- **Branch:** `feat/2-geodetic-system`
- **Pushed to origin:** yes

## Done (committed)
- **#80** — PropertyGrid.onSave typed as `void Function(String key, dynamic value)?` (was `Function?`). Removed dynamic try/catch fallback. Updated 3 test callbacks.
- **Protocol** — Step 8 clarified for meta-issues with multiple sub-items (loop per sub-item, don't stop to ask/report/plan)

## Current Issues
| # | Title | Priority |
|---|-------|----------|
| **83** | Eliminate ALL hardcoded data (14 items) | HIGH — next |
| 84 | UI acceptance tests | MEDIUM |
| 1-14 | RFC 9179 feature epics | LOW |

## Issue #83 — What's needed
Externalize 14 hardcoded data items to DB/config. Items:
1. Mock table data (Items/Status/Activity) → JSON or DB
2. Tab labels → config
3. Tree navigation data → JSON or DB
4. Expanded state defaults → constants
5. Theme dropdown → constants
6. Worker loop count → constants
7. PropertyGrid fallback defaults → remove
8. Theme colors (~40 const Color) → config
9. Topology seed data → JSON or DB
10. Attribute definitions → DB table
11. Validation enum → constants
12. UML metadata → constants
13. Column name → constants
14. DB table schema → constants

## Pre-existing Defects (not filed, block testing)
1. `PropertyGrid` missing `repository` parameter — 3 test files fail
2. `CartesianCoordinate` class missing
3. `validateLocationChoice`, `validateHeightAccuracyWithCartesian` — missing
4. `defaultCartesianAttributes` — missing from schema.dart
5. 42 analyzer errors across test files

All pre-existing (not introduced by this session). Should be fixed or filed before or alongside #83.

## Protocol
Use `prompts/debug-agent-prompt.md` — 8-step Recursive Debugging Protocol. Steps 1-7 each dispatch a fresh subagent. Step 8 loops for meta-issues. NEVER execute work directly.

## Karpathy Guidelines
1. Think before coding — state assumptions
2. Simplicity first — minimum code
3. Surgical changes — touch only what you must
4. Goal-driven execution — define success criteria, loop until verified
