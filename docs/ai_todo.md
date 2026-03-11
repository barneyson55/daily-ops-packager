# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 20:39 UTC.

## Current evidence snapshot

- Repo status at the start of this maintenance pass was **clean**: `git status --short --branch` returned only `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- `.github/workflows/windows-regression.yml` exists and runs `scripts\Regression.ps1` on `windows-latest` after installing AutoHotkey.
- `scripts/SmokeTest.ps1` now defaults to `config\fixtures\readiness.pass.ini`, seeds repo-local fixture env vars for the no-arg path, and restores the caller environment afterward.
- `scripts/Regression.ps1` still invokes `scripts\SmokeTest.ps1` with an explicit `-Config` argument, so CI/regression does **not** yet prove the literal no-argument contract that humans will use.
- Both `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` still exist with overlapping static validation scope.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**` and still tells the reader to run `scripts\SmokeTest.ps1 -Config config\app.ini`, which is now stale relative to README and the safer smoke-test default.
- Root `STATUS.md` is still stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging instead of the current confidence gaps.

## Prioritized open items

- [ ] **P0 — Add automated coverage for the literal no-argument smoke entrypoint**
  - **Why now:** the repo has already made the direct smoke path safer, but the automated regression surface still does not prove that `scripts\SmokeTest.ps1` with **no arguments** stays fixture-backed and non-secret.
  - **Deliverables:**
    - Extend `scripts/Regression.ps1`, the Windows workflow, or both so the literal no-arg `scripts\SmokeTest.ps1` path is exercised automatically.
    - Fail the automated check if the no-arg default drifts away from `config\fixtures\readiness.pass.ini`.
    - Keep the coverage repo-local and non-secret.
  - **Verification:**
    - `powershell -NoProfile -Command "Get-Content scripts\Regression.ps1,.github\workflows\windows-regression.yml | Select-String -Pattern 'SmokeTest\.ps1'"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
    - Successful output includes `Using repo-local readiness fixture: config\fixtures\readiness.pass.ini` and `Smoke test OK.` without requiring `-Config config\app.ini`.

- [ ] **P1 — Collapse duplicate headless static guards onto one canonical script**
  - **Why now:** `scripts/CheckHeadlessDefault.ps1` is already the stronger canonical guard, but `scripts/VerifyNonInteractiveDefault.ps1` still duplicates part of the same claim and adds maintenance drift.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical headless-default guard.
    - Delete `scripts/VerifyNonInteractiveDefault.ps1` or reduce it to a thin compatibility wrapper.
    - Update remaining references so the repo points to one canonical headless-check name.
  - **Verification:**
    - `grep -RIn "VerifyNonInteractiveDefault" README.md STATUS.md docs scripts .github`
    - `grep -RIn "CheckHeadlessDefault" README.md STATUS.md docs scripts .github`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`

- [ ] **P1 — Close the headless-default release gate with native Windows PASS evidence**
  - **Why now:** CI and static guards exist, but the release claim is still open because checked-in native Windows observation has not been captured.
  - **Deliverables:**
    - Run the safe capture from native Windows PowerShell.
    - Run the PASS-grade capture after directly observing that default runs stay headless unless `--interactive` is passed.
    - Update `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and scheduler proof when available.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this OpenClaw/WSL session still cannot launch the native Windows binaries required for the final proof run.

- [ ] **P2 — Sweep repo docs so smoke-test and headless-proof instructions match current safe defaults**
  - **Why now:** README now advertises fixture-backed no-arg smoke usage, but at least one high-visibility doc still points humans at `scripts\SmokeTest.ps1 -Config config\app.ini`, which weakens the safety story and can mislead validation.
  - **Deliverables:**
    - Align smoke-test examples across `README.md`, `docs/headless_default_release_gate.md`, `STATUS.md`, and other docs entrypoints.
    - Make the safe no-arg smoke path the documented default.
    - Keep `-Config config\app.ini` documented only as explicit opt-in for real/local config.
  - **Verification:**
    - `grep -RIn "SmokeTest\.ps1" README.md STATUS.md docs`
    - `grep -RIn "config\\app\.ini" README.md STATUS.md docs`
    - Human review confirms docs distinguish the safe fixture-backed default from the explicit live-config path.

- [ ] **P2 — Canonicalize status docs around current confidence gaps instead of installer packaging**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, and root `STATUS.md` still leads with the wrong milestone order.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so it matches current priorities: no-arg smoke coverage, duplicate-guard cleanup, native Windows proof, then documentation cleanup.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'Regression|SmokeTest|headless|CI|installer'"`

## Notes

- The queue now starts with the highest-impact **unblocked** gap: automated proof of the literal no-arg smoke entrypoint.
- The previous completed smoke-default hardening work was removed from the active queue so autopilot does not waste a top slot on already-landed behavior.
- Native Windows PASS evidence remains a real release blocker, but it stays below the unblocked code-quality work because it still cannot be completed from this WSL/OpenClaw session.
- The most important newly surfaced docs inconsistency is that `docs/headless_default_release_gate.md` still points at `-Config config\app.ini` even though the repo now documents a safer default smoke path.