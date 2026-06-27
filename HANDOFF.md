# Handoff — Next Session

## Git State
- **HEAD:** `349e60b` fixup: strengthen bug-only guardrail with Step 0 gate in debug protocol skill
- **Branch:** `feat/2-geodetic-system`
- **Pushed to origin:** yes

## Done (committed)
| Commit | Fix |
|--------|-----|
| `349e60b` | Protocol: Step 0 gate added, bug-only guardrail strengthened |
| `dc2516d` | Protocol moved to `skills/debug-protocol/SKILL.md` (proper skill format) |
| `88af390` | Protocol: bug-only scope guardrail added |
| `7317e8d` | Handoff: scope protocol to bug issues only |
| `ae4d4af` | Handoff: loop instructions for #83 meta-issue |
| `0b784b6` | Handoff: initial version |
| `a269d84` | **#80** PropertyGrid onSave typed, try/catch removed, tests updated |

## Current State
- **HEAD:** `349e60b` on branch `feat/2-geodetic-system` (pushed)

## Open Issues (bug protocol applies)
| # | Title | Priority |
|---|-------|----------|
| **83** | Eliminate ALL hardcoded data (14 items) | HIGH — next |
| 84 | UI acceptance tests | MEDIUM |

## Issue #83 — Loop Instructions
Treat each of the 14 items below as ONE pass through Steps 1-7. After Step 7 passes for an item, immediately dispatch Step 1 for the next item. Do NOT stop, report, ask, or plan between items — just keep looping.

Items:
1. Mock table data (Items/Status/Activity)
2. Tab labels
3. Tree navigation data
4. Expanded state defaults
5. Theme dropdown
6. Worker loop count
7. PropertyGrid fallback defaults
8. Theme colors (~40 const Color)
9. Topology seed data
10. Attribute definitions
11. Validation enum
12. UML metadata
13. Column name
14. DB table schema

## Pre-existing Defects (not filed, block testing)
1. `PropertyGrid` missing `repository` parameter
2. `CartesianCoordinate` class missing
3. `validateLocationChoice`, `validateHeightAccuracyWithCartesian` missing
4. `defaultCartesianAttributes` missing from schema.dart
5. 42 analyzer errors across test files

These are pre-existing (not introduced this session). Fix or file before/alongside #83.

## Protocol
- **Bug protocol:** `skills/debug-protocol/SKILL.md` — 8-step loop, Step 0 gates bugs only
- **Do NOT use for features** (#1-#14 are RFC 9179 epics, not bugs)
- Never execute work directly — only dispatch subagents

## Karpathy Guidelines
1. Think before coding — state assumptions
2. Simplicity first — minimum code
3. Surgical changes — touch only what you must
4. Goal-driven execution — define success criteria, loop until verified
