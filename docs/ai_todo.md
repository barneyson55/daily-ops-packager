# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 00:14 UTC.

## Current evidence snapshot

- Repo status at the start of this maintenance pass was **clean**: `git status --short --branch` returned `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence is still the main release-confidence gap.
- `README.md` and `docs/headless_default_release_gate.md` both now treat `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1` as the default safe smoke path, with `-Config config\app.ini` kept as explicit opt-in for local/live evidence.
- Root `STATUS.md` is still stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging instead of the current release gate and documentation gaps.
- At least one dated planning doc still advertises the old copy-pasteable live-config smoke command: `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` still references `scripts\SmokeTest.ps1 -Config config\app.ini`.
- `scripts/CheckHeadlessDefault.ps1` is the repo-facing canonical guard, but `scripts/VerifyNonInteractiveDefault.ps1` still exists as overlapping maintenance surface.

## Prioritized open items

- [ ] **P0 — Close the headless-default release gate with native Windows PASS evidence**
  - **Why now:** this is still the single biggest blocker to trustworthy release readiness. The guard, smoke path, wrapper, and PASS assert already exist; the missing piece is checked-in Windows proof.
  - **Deliverables:**
    - Run the safe native Windows evidence capture from a real Windows terminal.
    - Run the PASS-grade capture after directly observing that the default path stays headless unless `--interactive` is passed.
    - If `OneClickBackupDaily` exists, include scheduler proof in the same PASS-grade artifact.
    - Update `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and scheduler proof when applicable.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this WSL/OpenClaw session cannot launch the native Windows binaries needed for the final proof run.

- [ ] **P1 — Publish canonical status docs and align every status surface to the real blockers**
  - **Why now:** `docs/status.md` and `docs/critical_todo.md` are still missing, and root `STATUS.md` still tells an outdated story. Readers still have to piece together current reality from multiple files.
  - **Deliverables:**
    - Add `docs/status.md` with current state, evidence, and known limits.
    - Add `docs/critical_todo.md` containing only real blockers.
    - Reconcile root `STATUS.md` so it matches the actual order of work: native Windows PASS evidence first, then the next unblocked cleanup items.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'headless|SmokeTest|Regression|CI|installer'"`
    - Human review confirms all three status surfaces tell the same story.

- [ ] **P1 — Sweep stale smoke-command guidance so only deliberate opt-in or clearly historical contexts mention `-Config config\app.ini`**
  - **Why now:** the canonical docs are safe-first, but at least one dated planning doc still presents the old live-config smoke command in a copy-pasteable form.
  - **Deliverables:**
    - Update current guidance docs so the no-argument smoke path is the default recommendation everywhere canonical.
    - For dated planning docs, either remove stale command guidance or label it clearly as historical/non-canonical.
    - Keep `-Config config\app.ini` examples only where live/local config use is the explicit point.
  - **Verification:**
    - `rg -n "SmokeTest\\.ps1" README.md STATUS.md docs`
    - `rg -n "SmokeTest\\.ps1 -Config config\\app\\.ini" README.md STATUS.md docs`
    - Human review confirms every remaining `-Config config\app.ini` example is clearly opt-in or historical.

- [ ] **P2 — Collapse the duplicate static guard surface so one script is truly canonical**
  - **Why now:** user-facing references have already converged on `scripts/CheckHeadlessDefault.ps1`, but `scripts/VerifyNonInteractiveDefault.ps1` still adds drift risk without adding clear user value.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical guard.
    - Delete `scripts/VerifyNonInteractiveDefault.ps1` or reduce it to a thin compatibility wrapper that calls the canonical script.
    - Update any remaining repo references if new ones are found.
  - **Verification:**
    - `rg -n "VerifyNonInteractiveDefault|CheckHeadlessDefault" README.md STATUS.md docs scripts .github`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - If a wrapper is kept: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\VerifyNonInteractiveDefault.ps1`

## Notes

- The previously completed item for making evidence capture default to the repo-local readiness fixture-backed smoke path remains out of the active queue because the repo docs and wrapper flow are already aligned on that behavior.
- This refresh keeps the queue at four open items because they are the only currently evidenced tasks with clear release or maintenance impact.
- Missing `docs/status.md` and `docs/critical_todo.md` are tracked as real documentation work, not as path-discovery problems.
