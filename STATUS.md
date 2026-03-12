# STATUS

Last triage: 2026-03-12 (UTC)

## Canonical status surfaces
- `docs/status.md` — current release story and evidence boundaries
- `docs/critical_todo.md` — only the real blockers
- `docs/headless_default_release_gate.md` — durable native-Windows gate artifact

## Current release story
- **Main release blocker:** `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- **Automated coverage that already exists:** `.github/workflows/windows-regression.yml` runs `scripts\Regression.ps1` on `windows-latest` and covers the static headless guard, fixture-backed prereq checks, and the safe default smoke path.
- **What still needs native Windows evidence:** direct proof that the default path stays headless unless `--interactive` is passed, plus local scheduled-task audit/proof when applicable.

## Next work in order
1. Close the native Windows PASS evidence gate in `docs/headless_default_release_gate.md`.
2. Make the Windows regression workflow publish durable review artifacts.
3. Sweep stale smoke-command guidance so `scripts\SmokeTest.ps1 -Config config\app.ini` appears only as explicit opt-in or clearly historical context.
