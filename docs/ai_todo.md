# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 08:29 UTC.

## Current evidence snapshot

- Verified in this pass: `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git status --short --branch` is clean at the exact repo root: `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (`## master...origin/master`).
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence remains the main release-confidence blocker.
- Live GitHub re-check at `2026-03-12 08:29 UTC`: `gh run list --workflow windows-regression.yml --limit 8` still returns only failed runs, `gh run view 22991617584` and `gh run view 22989319342` both report a likely workflow-file issue, and `gh api repos/barneyson55/daily-ops-packager/actions/artifacts` still returns `{"total_count":0,"artifacts":[]}`.
- Status surfaces are now aligned on the important point: workflow artifacting is not the primary release blocker, but live artifact-download verification is still blocked until a green run exists.
- The checked-in gate doc still says the final PASS capture must come from a native Windows terminal, not from this WSL/OpenClaw session.

## Queueing rule for this file

- Lead with the highest-impact work that the current engineering environment can actually execute.
- Keep the blocked/manual native-Windows release gate visible, but do **not** leave it as the first unchecked item unless a native Windows terminal is actually available.
- Keep the top-level open queue short (target 3-7 items).

## Closed out of the queue in this pass

- [x] Verify that `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` exist.
- [x] Re-check working-tree state at the exact repo root.
- [x] Reconfirm that `docs/headless_default_release_gate.md` is still `PENDING_REAL_RUN`.
- [x] Re-check live GitHub Actions health for `windows-regression.yml` and resolve artifact-status drift.
- [x] Reconcile `STATUS.md`, `docs/status.md`, `docs/critical_todo.md`, and this queue to the freshly re-checked live artifact state.

## Prioritized open items

- [ ] **P1 — Download and inspect one real Windows regression artifact bundle end-to-end once a green run exists**
  - **Why first now:** the live GitHub re-check is done, so this becomes the next non-Windows verification step as soon as one green `windows-regression.yml` run exists.
  - **Deliverables:**
    - Download one artifact bundle from a successful `windows-regression.yml` run.
    - Confirm it contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - If the live artifact shape differs from docs, update the current-status docs and this queue immediately.
  - **Verification:**
    - `gh run download <run-id> --dir tmp/windows-regression-artifact`
    - `test -f tmp/windows-regression-artifact/regression.log`
    - `test -f tmp/windows-regression-artifact/regression-summary.md`
    - `test -f tmp/windows-regression-artifact/workflow-context.txt`
  - **Current blocker:** the live re-check at `2026-03-12 08:29 UTC` found no successful sampled run and no stored artifact bundle (`{"total_count":0,"artifacts":[]}`), so this stays blocked until the workflow-file failure is repaired and a green run lands.

- [ ] **P1 — Run the safe-first native Windows evidence capture and preserve the generated transcript**
  - **Why third:** this is the shortest path from “the tooling exists” to fresh machine-specific evidence without yet claiming PASS-grade observation.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal in the repo.
    - Confirm `docs\headless_default_release_gate.md` refreshes with current-run evidence.
    - Preserve the support transcript under `logs\headless_release_gate_*.log`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -Command "Get-ChildItem logs\headless_release_gate_*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1 FullName,LastWriteTime"`
    - `powershell -NoProfile -Command "Get-Content docs\headless_default_release_gate.md -TotalCount 40"`
  - **Current blocker:** requires a native Windows terminal; cannot be executed from this WSL/OpenClaw session.

- [ ] **P1 — Capture scheduler proof for `OneClickBackupDaily` if that task exists on the Windows host**
  - **Why fourth:** the release story still calls out scheduled-task audit/proof as required when applicable, and keeping it explicit prevents the final PASS item from hiding a scheduler-specific miss.
  - **Deliverables:**
    - Run the evidence capture with `-ScheduledTaskName "OneClickBackupDaily"` on the real Windows host.
    - Confirm the markdown artifact records `schtasks` query output and the task-action audit.
    - Record whether the task exists and, if it does, whether its action still avoids `--interactive` and still targets `OneClickBackup.ahk` with the expected config flag.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal and only applies if the scheduled task is actually present.

- [ ] **P0 — Close the headless-default release gate with PASS-grade native Windows evidence**
  - **Why fifth:** this is still the main release-confidence blocker, but it is downstream of direct human observation on a real Windows desktop.
  - **Deliverables:**
    - Rerun the wrapper in `-Mode Pass -ObservedBy "YourName"` after directly observing that the default path stays headless unless `--interactive` is passed.
    - Include `-ScheduledTaskName "OneClickBackupDaily"` when scheduler proof is required.
    - Update `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:'"`
  - **Current blocker:** this session cannot launch the native Windows binaries needed for the final proof run.


## Notes

- The open queue is intentionally split between blocked artifact-verification follow-up and blocked native-Windows evidence work.
- This pass closes the live GitHub Actions reality check and leaves artifact download verification blocked on a future green run.
- No source-code changes were made in this maintenance pass; only status/queue docs were updated.
