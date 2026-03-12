# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 04:22 UTC.

## Current evidence snapshot

- Verified in this pass: `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git status --short` currently shows one unrelated untracked docs file: `docs/research_handoff.md`. Leave it untouched unless a later pass explicitly scopes it in.
- `STATUS.md` and `docs/status.md` agree on the release story: `.github/workflows/windows-regression.yml` already runs `scripts\Regression.ps1` on `windows-latest`, uploads `regression.log`, `regression-summary.md`, and `workflow-context.txt`, and does **not** replace native Windows release proof.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence remains the main release-confidence blocker.
- Repo-wide reference checks now show one remaining docs cleanup surface:
  - stale live-config smoke guidance: `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` still contains `scripts\SmokeTest.ps1 -Config config\app.ini`
- `scripts/VerifyNonInteractiveDefault.ps1` is now only a thin compatibility wrapper around `scripts/CheckHeadlessDefault.ps1`, so the canonical static guard lives in one maintained script.
- This WSL/OpenClaw session cannot run the native Windows binaries needed for the final PASS capture, and it cannot prove a live GitHub Actions artifact upload end-to-end from local shell alone.

## Queueing rule for this file

- Lead with the highest-impact work that current automation can actually complete.
- Keep the blocked/manual release gate visible, but do **not** leave it as the first unchecked item unless a native Windows terminal is available.
- Keep the top-level open queue short (target 3-7 items when there is enough justified work).

## Recently completed

- [x] **P1 — Collapse the duplicate static guard surface so `scripts\CheckHeadlessDefault.ps1` is the single maintained guard**
  - `scripts/VerifyNonInteractiveDefault.ps1` now delegates directly to `scripts/CheckHeadlessDefault.ps1` as a thin compatibility wrapper.
  - Repo-wide reference checks found no remaining repo docs or automation that still depend on the old script as a separate maintained guard.
  - Remaining gap: this WSL session could not execute the PowerShell verification commands directly because no `powershell`/`pwsh` binary is available here.

- [x] **P1 — Make the Windows regression workflow publish durable review artifacts**
  - `.github/workflows/windows-regression.yml` now creates and uploads a regression artifact bundle on every run.
  - Repo docs now explain what those artifacts prove and what they do not prove.
  - Remaining gap: this session could not verify a live GitHub Actions run end-to-end.

## Prioritized open items

- [ ] **P2 — Remove or clearly quarantine stale `-Config config\app.ini` smoke guidance in dated docs**
  - **Why now:** this is now the highest-impact unblocked cleanup item. The currently confirmed docs hit is `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md`.
  - **Deliverables:**
    - Replace copy-pasteable live-config smoke guidance in dated docs with the safe no-argument smoke path, or label it clearly as historical/non-canonical.
    - Keep `-Config config\app.ini` examples only where live/local config use is the explicit point.
  - **Verification:**
    - `rg -n "SmokeTest\\.ps1" README.md STATUS.md docs`
    - `rg -n "SmokeTest\\.ps1 -Config config\\\\app\\.ini" README.md STATUS.md docs`
    - Human review confirms every remaining `-Config config\app.ini` example is clearly opt-in or historical.

- [ ] **BLOCKED MANUAL — Close the headless-default release gate with native Windows PASS evidence**
  - **Why second:** this is still the biggest release-confidence task, but it cannot be executed from the current WSL/OpenClaw session.
  - **Deliverables:**
    - Run the safe native Windows evidence capture from a real Windows terminal.
    - Rerun in `-Mode Pass -ObservedBy "YourName"` after directly observing that the default path stays headless unless `--interactive` is passed.
    - Include `-ScheduledTaskName "OneClickBackupDaily"` when scheduler proof is required.
    - Update `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and scheduler proof when applicable.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this session cannot launch the native Windows binaries needed for the final proof run.

## Notes

- The first unchecked item remains executable from a normal engineering environment.
- The native Windows PASS capture stays visible because it is still the main release blocker.
- The queue is intentionally capped at three open items until new evidence changes the release story.
