# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 01:25 UTC.

## Current evidence snapshot

- Repo status at the start of this maintenance pass was **clean**: `git status --short` returned no tracked-file changes.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence is still the main release-confidence gap.
- `README.md` and `docs/headless_default_release_gate.md` both now treat `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1` as the default safe smoke path, with `-Config config\app.ini` kept as explicit opt-in for local/live evidence.
- `.github/workflows/windows-regression.yml` already exists and runs `scripts\Regression.ps1` on `windows-latest` for `push`, `pull_request`, and `workflow_dispatch`.
- That CI surface still does **not** replace the manual PASS gate: the repo still requires native Windows observation for the no-dialog claim and optional local scheduled-task proof.
- Root `STATUS.md` is still stale (`Last triage: 2026-02-15 (UTC)`) and still leads with installer packaging instead of the current release gate and documentation gaps.
- At least one dated planning doc still advertises the old copy-pasteable live-config smoke command: `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` still references `scripts\SmokeTest.ps1 -Config config\app.ini`.
- `scripts/CheckHeadlessDefault.ps1` is the repo-facing canonical guard, but `scripts/VerifyNonInteractiveDefault.ps1` still exists as overlapping maintenance surface.

## Prioritized open items

- [ ] **P0 — Close the headless-default release gate with native Windows PASS evidence**
  - **Why now:** this is still the single biggest blocker to trustworthy release readiness. The guard, smoke path, wrapper, CI regression, and PASS assert already exist; the missing piece is checked-in Windows proof.
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

- [ ] **P1 — Publish canonical status docs that clearly separate CI coverage from the manual Windows release gate**
  - **Why now:** the repo now has both an automated Windows regression workflow and a manual PASS-grade release gate, but readers still have no single up-to-date status surface that explains the difference.
  - **Deliverables:**
    - Add `docs/status.md` with current state, evidence, and known limits.
    - Add `docs/critical_todo.md` containing only real blockers.
    - Reconcile root `STATUS.md` so it matches the actual order of work: native Windows PASS evidence first, then the next unblocked cleanup items.
    - Explicitly document that GitHub Actions covers static/prereq/fixture-backed regression, while native Windows manual evidence is still required for the no-dialog claim and local scheduled-task audit.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'headless|SmokeTest|Regression|windows-regression|scheduler|PENDING_REAL_RUN'"`
    - Human review confirms all three status surfaces tell the same story.

- [ ] **P1 — Make the existing Windows regression workflow produce durable review artifacts**
  - **Why now:** `.github/workflows/windows-regression.yml` already proves the repo can run fixture-backed regression on Windows CI, but the workflow is still mostly a pass/fail signal instead of a reusable evidence surface.
  - **Deliverables:**
    - Persist regression outputs/logs as downloadable workflow artifacts.
    - If needed, make `scripts\Regression.ps1` emit stable artifact files instead of console-only evidence.
    - Document in README/status docs what CI artifacts prove and what they still do **not** prove.
  - **Verification:**
    - `rg -n "upload-artifact|Regression\.ps1|SmokeTest|CheckPrereqs" .github/workflows/windows-regression.yml scripts/Regression.ps1`
    - A `workflow_dispatch` run in GitHub Actions shows downloadable regression artifacts.
    - README/status docs point readers to the artifact surface and still keep the manual PASS gate separate.
  - **Current blocker:** workflow-run verification requires GitHub access and a successful Windows runner execution.

- [ ] **P2 — Sweep stale smoke-command guidance so only deliberate opt-in or clearly historical contexts mention `-Config config\app.ini`**
  - **Why now:** the canonical docs are safe-first, but at least one dated planning doc still presents the old live-config smoke command in copy-pasteable form.
  - **Deliverables:**
    - Update current guidance docs so the no-argument smoke path is the default recommendation everywhere canonical.
    - For dated planning docs, either remove stale command guidance or label it clearly as historical/non-canonical.
    - Keep `-Config config\app.ini` examples only where live/local config use is the explicit point.
  - **Verification:**
    - `rg -n "SmokeTest\.ps1" README.md STATUS.md docs`
    - `rg -n "SmokeTest\.ps1 -Config config\\app\.ini" README.md STATUS.md docs`
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

- This refresh removes the now-obsolete notion that the repo still needs a Windows CI baseline from scratch: `.github/workflows/windows-regression.yml` already exists.
- The active gap is now the boundary between **automated Windows regression evidence** and **manual Windows PASS-grade release proof**.
- Missing `docs/status.md` and `docs/critical_todo.md` are tracked as real documentation work, not as path-discovery problems.
- This queue stays at five open items because they are the only currently evidenced tasks with clear release, reliability, or maintenance impact.
