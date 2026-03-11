# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 22:00 UTC.

## Current evidence snapshot

- Repo status at the start of this maintenance pass was **clean**: `git status --short --branch` returned only `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- `.github/workflows/windows-regression.yml` exists on `windows-latest` and runs `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`.
- `scripts/Regression.ps1` now explicitly exercises the literal no-argument smoke path (`Dry-run smoke path (literal no-arg default)`) and expects `Using repo-local readiness fixture: config\fixtures\readiness.pass.ini` plus `Smoke test OK.`.
- `scripts/SmokeTest.ps1` still defaults to `config\fixtures\readiness.pass.ini`, seeds repo-local fixture env vars for that default path, and restores the caller environment afterward.
- `scripts/CheckHeadlessDefault.ps1` and `scripts/VerifyNonInteractiveDefault.ps1` still both exist with overlapping static validation scope.
- `scripts/CaptureHeadlessEvidence.ps1` and `scripts/RunHeadlessEvidenceCapture.ps1` now default to `config\fixtures\readiness.pass.ini`, and the capture flow now records the smoke step as the literal no-argument `scripts\SmokeTest.ps1` command when that safe default is in effect.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, but its verification commands now make the no-arg smoke/default path primary and keep `-Config config\app.ini` as explicit opt-in.
- Root `STATUS.md` is still stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging instead of the current confidence gaps.
- At least one dated planning doc still advertises the old smoke command (`docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` references `scripts\SmokeTest.ps1 -Config config\app.ini`), so stale guidance is not isolated to one file.

## Prioritized open items

- [x] **P0 — Make headless evidence capture use the safe fixture-backed smoke path by default**
  - `scripts/CaptureHeadlessEvidence.ps1` and `scripts/RunHeadlessEvidenceCapture.ps1` now default to the repo-local readiness fixture (`config\fixtures\readiness.pass.ini`).
  - The captured smoke step now uses the literal no-argument `scripts\SmokeTest.ps1` command when that safe default is active, while keeping `-Config config\app.ini` as an explicit opt-in override.
  - `README.md` and `docs/headless_default_release_gate.md` now describe the same safe-first evidence-capture contract.
  - Repo-local verification in this pass: `git diff --check -- scripts/CaptureHeadlessEvidence.ps1 scripts/RunHeadlessEvidenceCapture.ps1 README.md docs/headless_default_release_gate.md` plus `rg -n "config\\app\.ini|fixtures\\readiness\.pass\.ini|SmokeTest\.ps1|RunHeadlessEvidenceCapture\.ps1" scripts/CaptureHeadlessEvidence.ps1 scripts/RunHeadlessEvidenceCapture.ps1 README.md docs/headless_default_release_gate.md`.
  - Remaining blocker for full end-to-end proof: native Windows execution is still required for `scripts\RunHeadlessEvidenceCapture.ps1`.

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
  - **Why now:** the static guard, regression suite, assert script, and capture wrapper all exist, but the release claim is still open because checked-in native Windows observation has not been captured.
  - **Deliverables:**
    - Run the safe native Windows capture after the safe-default smoke path above is aligned.
    - Run the PASS-grade capture after directly observing that default runs stay headless unless `--interactive` is passed.
    - Update `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and scheduler proof when available.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this OpenClaw/WSL session still cannot launch the native Windows binaries required for the final proof run.

- [ ] **P2 — Canonicalize status docs around current confidence gaps instead of installer packaging**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, and root `STATUS.md` still leads with the wrong milestone order.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so it matches current priorities: safe evidence capture, duplicate-guard cleanup, native Windows proof, then broader doc cleanup.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'Regression|SmokeTest|headless|CI|installer'"`

- [ ] **P2 — Sweep stale doc references so only explicit opt-in contexts mention `config\app.ini` smoke usage**
  - **Why now:** the repo now has a safer fixture-backed smoke default and automated coverage for it, but older docs still advertise `scripts\SmokeTest.ps1 -Config config\app.ini` in places that can read like current guidance.
  - **Deliverables:**
    - Update current guidance docs to make the no-arg smoke path the default recommendation.
    - For dated planning docs, either remove stale command guidance or label it clearly as historical/non-canonical.
    - Keep `-Config config\app.ini` documented only where live/local config is the deliberate point.
  - **Verification:**
    - `grep -RIn "SmokeTest\.ps1" README.md STATUS.md docs`
    - `grep -RIn "SmokeTest\.ps1 -Config config\\app\.ini" README.md STATUS.md docs`
    - Human review confirms every remaining `-Config config\app.ini` example is clearly explicit opt-in or historical.

## Notes

- The previous top item for automated proof of the literal no-argument smoke entrypoint was removed from the active queue because it is now landed in `scripts/Regression.ps1` and exercised by the Windows regression workflow.
- The safe smoke default and the human-facing headless evidence capture path are now aligned on the same repo-local fixture-backed default.
- Native Windows PASS evidence remains a real release blocker, but it stays below the highest-impact unblocked code/doc alignment work because it still cannot be completed from this WSL/OpenClaw session.
- Missing `docs/status.md` and `docs/critical_todo.md` are tracked as real documentation work, not as path-discovery problems.