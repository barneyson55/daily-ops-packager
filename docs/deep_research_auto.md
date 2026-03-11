# Deep Research — daily-ops-packager

Updated: 2026-03-11 18:44 UTC
Scope of this pass: local repo evidence only, docs-only maintenance pass, no source-code changes.

## Sources reviewed

### Local repo evidence
- `git status --short --branch`
- `STATUS.md`
- `README.md`
- `USER_TODO.md`
- `docs/ai_todo.md` (pre-refresh)
- `docs/deep_research_auto.md` (pre-refresh)
- `docs/headless_default_release_gate.md`
- existence checks for `docs/status.md` and `docs/critical_todo.md`
- existence checks for `.github/workflows/`
- `scripts/Regression.ps1`
- `scripts/SmokeTest.ps1`
- `scripts/CheckHeadlessDefault.ps1`
- `scripts/VerifyNonInteractiveDefault.ps1`
- `scripts/RunHeadlessEvidenceCapture.ps1`
- `scripts/AssertHeadlessReleaseGate.ps1`
- `config/readiness.contract.ini`
- `config/fixtures/readiness.pass.ini`
- `config/fixtures/readiness.fail-watchdir.ini`
- `config/fixtures/readiness.fail-email.ini`

## What changed since the previous research pass

### 1) The canonical regression entrypoint now exists
Evidence:
- `scripts/Regression.ps1` is now present.
- `README.md` now references `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1` as the canonical repo-local regression command.
- The script currently runs:
  - `scripts/CheckHeadlessDefault.ps1`
  - `scripts/CheckPrereqs.ps1` against pass/fail fixture configs
  - `scripts/SmokeTest.ps1` with `SmokeConfig = "config\fixtures\readiness.pass.ini"` by default

Consequence:
- The prior `docs/ai_todo.md` / `docs/deep_research_auto.md` claim that no canonical regression command exists is now stale and had to be removed.
- Future prioritization should build on the regression command rather than asking for it again.

### 2) The repo is still clean in this maintenance pass
Evidence:
- `git status --short --branch` returned only `## master...origin/master` before docs were refreshed.

Consequence:
- Prioritization should focus on open engineering gaps, not workspace cleanup.

## Highest-impact findings from current repo evidence

### 1) The best new leverage point is CI, not another local test wrapper
Evidence:
- `scripts/Regression.ps1` now exists and exercises the main repo-local confidence surface.
- `.github/workflows/` is still missing.

Implication:
- The repo has a usable local regression entrypoint but no automated enforcement on branch changes.

Roadmap consequence:
- The next highest-leverage task is a lightweight Windows CI workflow that runs `scripts\Regression.ps1`.

### 2) Direct smoke-test usage is still less deterministic than regression
Evidence:
- `scripts/SmokeTest.ps1` still defaults to `config\app.ini`.
- `scripts/Regression.ps1` deliberately overrides that by defaulting `SmokeConfig` to `config\fixtures\readiness.pass.ini`.

Implication:
- The canonical regression path is now safer than the obvious one-off smoke command.
- Humans following direct smoke instructions can still accidentally depend on local/live config.

Roadmap consequence:
- Align `scripts/SmokeTest.ps1` defaults and docs with the fixture-backed regression path.

### 3) Headless static validation is still duplicated
Evidence:
- `scripts/CheckHeadlessDefault.ps1` exists and is referenced by `README.md`.
- `scripts/VerifyNonInteractiveDefault.ps1` still exists.
- Repo-wide references still show `VerifyNonInteractiveDefault` surviving mainly in planning docs.

Implication:
- The duplicate script adds naming drift and maintenance risk without obvious extra value.

Roadmap consequence:
- Collapse onto `scripts/CheckHeadlessDefault.ps1` as the single canonical headless guard.

### 4) The headless-default release gate is still open and blocked on native Windows execution
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- `scripts/RunHeadlessEvidenceCapture.ps1` and `scripts/AssertHeadlessReleaseGate.ps1` exist.

Implication:
- The release-gate problem is no longer missing scaffolding; it is missing final native-Windows evidence.

Roadmap consequence:
- Keep this in the top tier, but below unblocked repo-local engineering work.

### 5) Release-state docs are still fragmented and partially stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still says `Last triage: 2026-02-15 (UTC)` and still leads with installer packaging.

Implication:
- A reader landing on the obvious status docs can still get the wrong story about what matters next.

Roadmap consequence:
- Refresh status-doc topology after the CI/smoke/headless-confidence work is better aligned.

## Recommended roadmap order

### Now / highest leverage
1. Add a lightweight Windows CI workflow that runs `scripts\Regression.ps1`.
2. Make `scripts\SmokeTest.ps1` deterministic and safe by default when invoked directly.
3. Collapse duplicate headless static guards onto `scripts\CheckHeadlessDefault.ps1`.
4. Close the headless-default release gate with native Windows PASS evidence.
5. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md`.

## Explicitly removed from the active top queue

- “Add `scripts/Regression.ps1`” — already landed.
- Any queue text that still claims the repo lacks a canonical regression command.

## Assumptions

- The checked-in readiness fixtures remain the intended non-secret baseline for local regression and future CI.
- The main distribution target is still a Windows user running AutoHotkey + PowerShell + rclone locally or via Task Scheduler.
- The headless-default release claim should not be treated as closed until native Windows evidence is committed.
- This maintenance pass is docs-only, so missing docs are recorded as roadmap gaps rather than created here.

## Unknowns for a future pass

- What is the best CI installation path for AutoHotkey v2 on GitHub-hosted Windows runners?
- Should `scripts/SmokeTest.ps1` switch its default config entirely, or should it force explicit opt-in for live `config\app.ini` usage?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or kept as a compatibility shim?
- After CI and headless proof are in place, is installer packaging still the next strategic milestone?

## Resulting prioritization change

This refresh changes the queue materially:

1. **Removed** the stale claim that `scripts/Regression.ps1` does not exist.
2. **Promoted** Windows CI to the first executable repo task because the regression command is already present.
3. **Kept** smoke determinism as a top-tier task, but now as a follow-on cleanup to align direct usage with regression.
4. **Kept** the native-Windows evidence task in the top tier, but below unblocked repo-local work.
5. **Kept** status-doc canonicalization as cleanup after confidence-building work, not as a substitute for it.