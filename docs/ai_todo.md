# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 06:53 UTC.

## Current evidence snapshot

- Verified in this pass: `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git status --short` is clean at the exact repo root: `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager`.
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`, so checked-in native Windows PASS evidence remains the main release-confidence blocker.
- Fresh GitHub Actions evidence now shows the artifact-verification step is blocked: `gh run list --workflow windows-regression.yml --limit 8` returns only failed runs in the latest sample, `gh run view 22989319342` reports `This run likely failed because of a workflow file issue.`, and `gh api repos/barneyson55/daily-ops-packager/actions/artifacts` returns `{"total_count":0,"artifacts":[]}`.
- `STATUS.md` and `docs/status.md` have been updated in this pass so they no longer overstate live artifact availability.
- Repo-wide fixed-string search for `-Config config\app.ini` no longer shows a stale dated-doc cleanup target under `docs/`; the remaining hits are intentional README/gate/script references.
- This WSL/OpenClaw session still cannot run the native Windows binaries needed for the final PASS capture.

## Queueing rule for this file

- Lead with the highest-impact work that a normal engineering environment can actually complete.
- Keep the blocked/manual release gate visible, but do **not** leave it as the first unchecked item unless a native Windows terminal is available.
- Keep the top-level open queue short (target 3-7 items).

## Closed out of the queue in this pass

- [x] Re-verify the canonical docs surfaces exist.
- [x] Re-check working-tree state at the exact repo root; there are no pending tracked or untracked changes to account for.
- [x] Re-check the old live-config smoke-command cleanup target; the previously cited dated docs hit is no longer an active gap.

## Prioritized open items

- [ ] **P1 — Verify one real Windows regression artifact bundle end-to-end from GitHub Actions**
  - **Why first:** repo docs rely on the claim that workflow runs publish durable reviewer artifacts, and the quickest way to validate or falsify that from a non-Windows environment is still an actual artifact download.
  - **Deliverables:**
    - Restore one successful `windows-regression.yml` run with a downloadable artifact bundle.
    - Download that bundle.
    - Confirm it contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - If the live artifact shape differs from docs, feed that mismatch back into the status docs and this queue.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 8`
    - `gh run view <run-id>`
    - `gh api repos/barneyson55/daily-ops-packager/actions/artifacts`
    - `gh run download <run-id> --dir tmp/windows-regression-artifact`
    - `test -f tmp/windows-regression-artifact/regression.log && test -f tmp/windows-regression-artifact/regression-summary.md && test -f tmp/windows-regression-artifact/workflow-context.txt`
  - **Current blocker:** GitHub CLI auth/network are working, but the latest checked runs are all failing, GitHub reports the newest run as `This run likely failed because of a workflow file issue.`, and the repo currently has zero stored Actions artifacts (`{"total_count":0,"artifacts":[]}`). Required human action: fix the workflow-file issue or otherwise produce one successful `windows-regression.yml` run, then rerun the artifact download verification.

- [ ] **P1 — Run the safe-first native Windows evidence capture and preserve the generated transcript**
  - **Why second:** this is the shortest path from “docs say the tooling exists” to fresh machine-specific evidence, without yet claiming PASS-grade observation.
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
  - **Why third:** the release story explicitly calls out scheduled-task audit/proof as remaining evidence when applicable; keeping it separate prevents the final PASS item from hiding a scheduler-specific miss.
  - **Deliverables:**
    - Run the capture with `-ScheduledTaskName "OneClickBackupDaily"` on the real Windows host.
    - Confirm the markdown artifact records `schtasks` query output and the task-action audit.
    - Record whether the task exists, and if it does, whether its action still avoids `--interactive` and still targets `OneClickBackup.ahk` with the expected config flag.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal and only applies if the scheduled task is actually present.

- [ ] **P0 — Close the headless-default release gate with PASS-grade native Windows evidence**
  - **Why fourth:** this is still the main release-confidence blocker, but it depends on direct human observation on a real Windows desktop.
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

- [ ] **P2 — Reconcile status surfaces immediately after new live evidence lands**
  - **Why fifth:** once item 1 and/or item 4 completes, the repo will otherwise keep advertising stale blocker wording even though the underlying evidence has changed.
  - **Deliverables:**
    - Update `STATUS.md`, `docs/status.md`, `docs/critical_todo.md`, and `docs/ai_todo.md` so they point to the newly verified artifact bundle and/or PASS gate state.
    - Remove any now-stale `PENDING_REAL_RUN` blocker language from current-status docs.
  - **Verification:**
    - `rg -n --fixed-strings 'PENDING_REAL_RUN' STATUS.md docs/status.md docs/critical_todo.md docs/ai_todo.md docs/headless_default_release_gate.md`
    - `rg -n --fixed-strings 'regression.log' STATUS.md docs/status.md docs/critical_todo.md docs/ai_todo.md`
  - **Current blocker:** depends on fresh evidence from item 1 and/or item 4.

## Notes

- The stale queue item about a remaining dated-doc smoke-command cleanup has been removed because current repo evidence no longer supports it.
- The queue is now expanded to five open items so the next steps stay actionable instead of collapsing multiple distinct evidence tasks into one blocked line.
- No source-code changes were made in this maintenance pass.
