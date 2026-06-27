# Handoff

## State

HEAD `92b9171` on `feat/2-geodetic-system` — pushed to origin.

### Done
- `a269d84` — **#80** PropertyGrid `onSave` typed, try/catch removed, 3 test callbacks updated
- `349e60b` — `skills/debug-protocol/SKILL.md` created with 8-step loop + Step 0 bug gate

### Open Bugs
- **#83** — Eliminate ALL hardcoded data (14 sub-items)
- **#84** — Write UI acceptance tests

### Pre-existing (not created this session)
- 42 analyzer errors in test files (missing `CartesianCoordinate`, `validateLocationChoice`, `repository` param, etc.)
- 3 test files fail to compile

These block testing. The next agent should file them as issues or fix them before/alongside #83.

## Execution Plan

1. Load `skills/debug-protocol/SKILL.md`
2. Step 0: Confirm the issue is a bug before proceeding
3. Execute Steps 1-7 per sub-item on **all open bug issues**, looping without stopping until ALL are closed
4. Subagents may file new issues during execution — those must also be processed
5. Do NOT stop until ZERO open bugs remain
