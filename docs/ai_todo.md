# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 05:31 UTC.

## Current evidence snapshot

- Verified in this pass: `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git status --short` now shows docs-only changes for this milestone in `STATUS.md`, `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md`, `docs/ai_todo.md`, and `docs/status.md`.
- `STATUS.md` and `docs/status.md` still agree on the release story: `.github/workflows/windows-regression.yml` runs `scripts\Regression.ps1` on `windows-latest`, uploads `regression.log`, `regression-summary.md`, and `workflow-context.txt`, and does **not** replace native Windows release proof.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence remains the main release-confidence blocker.
- Repo-wide fixed-string search for `-Config config\app.ini` no longer finds copy-pasteable live-config smoke guidance in dated planning docs:
  - `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` now points to the safe no-argument smoke command
  - remaining hits are explicit opt-in guidance, status notes, or historical research/queue docs
- This WSL/OpenClaw session cannot run the native Windows binaries needed for the final PASS capture, and it cannot independently prove a live GitHub Actions artifact download end-to-end from local shell alone.

## Queueing rule for this file

- Lead with the highest-impact work that a normal engineering environment can actually complete.
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

- [x] **P1 — Quarantine the remaining stale live-config smoke command in dated docs**
  - `docs/aspm_sellable_delivery_scope_2026-02-16_wave2.md` now uses the safe no-argument smoke path instead of the copy-pasteable live-config smoke command.
  - `rg -n --fixed-strings -- "-Config config\\app.ini" README.md STATUS.md docs` no longer shows that dated planning doc as a remaining hit.
  - Remaining `-Config config\app.ini` references are explicit opt-in guidance, status notes, or clearly historical research/queue docs.

## Prioritized open items

- [ ] **P2 — Verify one real Windows regression artifact bundle end-to-end from GitHub Actions**
  - **Why first:** repo docs now rely on the claim that workflow runs publish durable reviewer artifacts, but this local pass only proves the workflow/docs wiring, not a real downloadable bundle from a completed run.
  - **Deliverables:**
    - Download the latest successful `windows-regression.yml` artifact bundle.
    - Confirm it contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - If the live artifact shape differs from docs, feed that mismatch back into the status docs and this queue.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh run download <run-id> --dir tmp/windows-regression-artifact`
    - `test -f tmp/windows-regression-artifact/regression.log && test -f tmp/windows-regression-artifact/regression-summary.md && test -f tmp/windows-regression-artifact/workflow-context.txt`
  - **Current blocker:** requires GitHub CLI access/auth plus network access to Actions artifacts.

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

- The first unchecked item remains executable from a normal engineering environment without touching source code.
- The native Windows PASS capture stays visible because it is still the main release blocker.
- The queue is intentionally capped at two open items because only two evidence-backed priorities remain right now.
