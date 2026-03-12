# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 03:10 UTC.

## Current evidence snapshot

- This pass updated `.github/workflows/windows-regression.yml` so the Windows regression job now uploads a durable artifact bundle with `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
- The workflow summary artifact now states what CI proves (static guard + fixture-backed prereq checks + safe default smoke path on `windows-latest`) and what it still does **not** prove (native desktop observation, PASS-grade gate evidence, or local scheduled-task behavior).
- `STATUS.md`, `docs/status.md`, `docs/critical_todo.md`, and `README.md` now reflect that workflow artifacting exists and does not replace the native Windows PASS gate.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence is still the main release-confidence blocker.
- Stale live-config smoke guidance still exists in dated docs: `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` still references `scripts\SmokeTest.ps1 -Config config\app.ini`.
- `scripts/CheckHeadlessDefault.ps1` is the repo-facing canonical guard, but `scripts/VerifyNonInteractiveDefault.ps1` still exists as overlapping maintenance surface.
- This WSL/OpenClaw pass cannot complete the final native-Windows proof run or verify a real GitHub Actions artifact upload end-to-end.

## Queueing rule for this file

- Lead with the highest-impact work that current automation can actually complete.
- Keep blocked/manual items visible, but do **not** leave them as the first unchecked item unless the required environment is available.

## Recently completed

- [x] **P1 — Make the Windows regression workflow publish durable review artifacts**
  - `.github/workflows/windows-regression.yml` now creates and uploads a regression artifact bundle on every run.
  - Repo docs now explain what those artifacts prove and what they do not prove.
  - Remaining gap: this session could not verify a live GitHub Actions run end-to-end.

## Prioritized open items

- [ ] **P1 — Collapse the duplicate static guard surface so one script is truly canonical**
  - **Why now:** this is the next-best unblocked reliability task. Keeping both `CheckHeadlessDefault.ps1` and `VerifyNonInteractiveDefault.ps1` invites drift in the exact guard that CI and release docs depend on.
  - **Deliverables:**
    - Keep `scripts/CheckHeadlessDefault.ps1` as the canonical guard.
    - Delete `scripts/VerifyNonInteractiveDefault.ps1` or reduce it to a thin compatibility wrapper that calls the canonical script.
    - Update any remaining repo references if new ones are found.
  - **Verification:**
    - `rg -n "VerifyNonInteractiveDefault|CheckHeadlessDefault" README.md STATUS.md docs scripts .github`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - If a wrapper is kept: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\VerifyNonInteractiveDefault.ps1`

- [ ] **P2 — Sweep stale smoke-command guidance so only deliberate opt-in or clearly historical contexts mention `-Config config\app.ini`**
  - **Why now:** canonical docs are already safe-first, but at least one dated planning doc still presents the old live-config smoke command in copy-pasteable form.
  - **Deliverables:**
    - Update current guidance docs so the no-argument smoke path is the default recommendation everywhere canonical.
    - For dated planning docs, either remove stale command guidance or label it clearly as historical/non-canonical.
    - Keep `-Config config\app.ini` examples only where live/local config use is the explicit point.
  - **Verification:**
    - `rg -n "SmokeTest\.ps1" README.md STATUS.md docs`
    - `rg -n "SmokeTest\.ps1 -Config config\\app\.ini" README.md STATUS.md docs`
    - Human review confirms every remaining `-Config config\app.ini` example is clearly opt-in or historical.

- [ ] **BLOCKED MANUAL — Close the headless-default release gate with native Windows PASS evidence**
  - **Why still listed:** this remains the main release-confidence blocker, but it cannot be completed from this WSL/OpenClaw session and therefore should not be the first unchecked item until a native Windows terminal is available.
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
  - **Current blocker:** this session cannot launch the native Windows binaries needed for the final proof run.

## Notes

- The first unchecked item now reflects the highest-impact task that current automation can still complete.
- The native Windows PASS capture remains the main release blocker; it is parked lower only because the current environment cannot complete it.
- End-to-end verification of the new GitHub Actions artifact bundle still requires a real `workflow_dispatch` run in GitHub Actions.
