# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 12:03 UTC.

## Current evidence snapshot

- Verified in this pass at the requested repo root: `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- The working tree is already dirty in this repo (`M docs/ai_todo.md`, `M docs/deep_research_auto.md`), so follow-up edits should stay narrowly scoped.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`.
- `gh run list --workflow windows-regression.yml --limit 5` now shows the latest sampled run succeeded: `22997394546` (`Windows regression`, `master`, `success`).
- `gh run view 22997394546` shows the `regression` job completed successfully, including the `Upload regression artifact bundle` step.
- `gh api repos/barneyson55/daily-ops-packager/actions/runs/22997394546/artifacts` returns one stored artifact: `windows-regression-22997394546-1` (artifact id `5888386046`, not expired).
- That clears the upstream CI repair blocker; the next actionable step is to download and inspect the successful artifact bundle.

## Queueing rule for this file

- Lead with the next highest-leverage item supported by fresh evidence.
- Keep the blocked native-Windows release gate visible, but do **not** put it first while cheaper CI/artifact verification remains unfinished.
- Keep the top-level open queue short (target 3-7 items).

## Closed out of the queue in this pass

- [x] Verify that `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` exist.
- [x] Re-read the current status docs before reprioritizing the queue.
- [x] Reconfirm that `docs/headless_default_release_gate.md` is still `PENDING_REAL_RUN`.
- [x] **P0 — Repair `windows-regression.yml` until one green run completes and uploads artifacts**
  - **Evidence:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh run view 22997394546`
    - `gh api repos/barneyson55/daily-ops-packager/actions/runs/22997394546/artifacts`
    - Success condition met: run `22997394546` concluded `success`, job step `Upload regression artifact bundle` passed, and stored artifact `windows-regression-22997394546-1` is available for download.

## Prioritized open items

- [ ] **P1 — Download one successful Windows regression artifact bundle and verify the expected file set**
  - **Why first now:** the green run and stored artifact now exist, so this is the fastest way to convert CI success into reviewer-usable evidence.
  - **Deliverables:**
    - Download one artifact bundle from a successful `windows-regression.yml` run.
    - Confirm it contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - If the live artifact contents differ from docs, update the relevant status docs immediately.
  - **Verification:**
    - `gh run download 22997394546 --dir tmp/windows-regression-artifact`
    - `test -f tmp/windows-regression-artifact/regression.log`
    - `test -f tmp/windows-regression-artifact/regression-summary.md`
    - `test -f tmp/windows-regression-artifact/workflow-context.txt`
  - **Current blocker:** none in this environment.

- [ ] **P1 — Run native Windows headless-evidence capture, including scheduler audit if `OneClickBackupDaily` exists**
  - **Why second:** after CI artifact verification, the next missing proof is fresh native-machine Windows evidence.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so the scheduler audit is captured in the markdown/log output.
    - Preserve the newest `logs\headless_release_gate_*.log` transcript.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -Command "Get-ChildItem logs\headless_release_gate_*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1 FullName,LastWriteTime"`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal; this WSL/OpenClaw session cannot perform the observed run.

- [ ] **P0 — Close `docs/headless_default_release_gate.md` with PASS-grade native Windows evidence**
  - **Why third:** this is still the checked-in release blocker even after the CI workflow repair was cleared.
  - **Deliverables:**
    - Rerun the wrapper in `-Mode Pass -ObservedBy "YourName"` after directly observing headless-by-default behavior on a native Windows desktop.
    - Ensure `docs/headless_default_release_gate.md` flips from `PENDING_REAL_RUN` to `PASS`.
    - Validate the final artifact with the repo assertion script.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:'"`
  - **Current blocker:** requires real Windows observation and cannot be closed from this environment.

- [ ] **P1 — Reconcile `STATUS.md`, `docs/status.md`, `docs/critical_todo.md`, and this queue immediately after fresh evidence lands**
  - **Why last:** docs should move right after the facts change, not before, but this should stay scoped to the new evidence rather than turning into broad doc churn.
  - **Deliverables:**
    - Refresh timestamps and status language after the green CI artifact run and after any future native Windows proof run.
    - Remove stale claims about zero artifacts / workflow-file failures once disproven.
    - Keep blocker language consistent across the four status surfaces.
  - **Verification:**
    - `grep -n "08:29 UTC\|workflow-file issue\|total_count.:0\|PENDING_REAL_RUN" STATUS.md docs/status.md docs/critical_todo.md docs/ai_todo.md`
    - Manual diff review across the four status surfaces.
  - **Current blocker:** none, but it should be handled in a tightly scoped docs pass.

## Notes

- The requested P0 CI milestone is now satisfied by live GitHub evidence, so the queue moves to artifact inspection and native-Windows proof.
- Native Windows PASS evidence remains the actual checked-in release blocker.
- No source-code changes were made in this pass.
