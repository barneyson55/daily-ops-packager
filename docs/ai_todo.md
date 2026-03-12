# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 14:42 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath: `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only pass: `## master...origin/master`.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`.
- The latest known green CI evidence remains `windows-regression.yml` run `22997394546`, and its downloaded artifact bundle contains the intended review files:
  - `regression.log`
  - `regression-summary.md`
  - `workflow-context.txt`
- But that same `regression.log` still contains `This script requires AutoHotkey v2.0.` and `Current interpreter: AutoHotkey v1.1.36.02 Unicode 64-bit` before ending with `Regression suite OK.`
- Consequence: CI is green, but the current workflow may still allow a wrong-interpreter false positive.
- `docs/status.md` and `docs/critical_todo.md` are stale relative to that verified green run because they still describe the earlier workflow-failure / zero-artifact state.

## Queueing rule for this file

- Fix proof quality before doc sync.
- Keep only 3-7 concrete open items.
- Each item must end with a check that can clearly pass or fail.

## Prioritized open items

- [ ] **P0 — Make Windows regression fail hard when AutoHotkey v1 or the v2-required banner appears**
  - **Why first:** the repo now has a green CI run, but its artifact log still shows a wrong-runtime warning path. Until the workflow rejects that state, CI can overstate release confidence.
  - **Deliverables:**
    - Make the workflow and/or smoke path resolve an explicit AutoHotkey v2 executable instead of tolerating ambiguous `AutoHotkey.exe` discovery.
    - Make `scripts\SmokeTest.ps1` and/or `scripts\Regression.ps1` fail if the run emits `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
    - Publish one new successful `windows-regression.yml` run whose artifact log is free of those wrong-runtime strings.
  - **Verification:**
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `python - <<'PY'
from pathlib import Path
p = next(Path('tmp/windows-regression-artifact').glob('**/regression.log'))
raw = p.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** requires source/workflow changes plus a fresh Windows Actions run; cannot be closed in this docs-only pass.

- [ ] **P0 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why second:** even with trustworthy CI, the checked-in release blocker remains direct native-Windows observation that the default path stays headless unless `--interactive` is passed.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so the artifact captures scheduler-query output and action-audit evidence.
    - Rerun in `-Mode Pass -ObservedBy "YourName"`, preserve the newest `logs\headless_release_gate_*.log`, and update `docs\headless_default_release_gate.md` from `PENDING_REAL_RUN` to `PASS`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:|OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal plus human desktop observation; cannot be closed from this WSL/OpenClaw session.

- [ ] **P1 — Refresh stale status docs immediately after either evidence-bearing item lands**
  - **Why last:** the status docs are behind reality, but fixing them before CI/runtime proof or native PASS evidence changes would create avoidable doc churn.
  - **Deliverables:**
    - Update `docs/status.md` and `docs/critical_todo.md` so they stop claiming the latest sampled workflow runs are only failures or that the repo has zero stored artifacts.
    - Keep the docs explicit that green CI artifact verification does **not** replace the native Windows PASS gate.
    - Record the newest run id and evidence timestamp used for the refresh.
  - **Verification:**
    - `grep -n "workflow file issue\|total_count.:0\|only failure\|only failures\|zero stored artifacts\|PENDING_REAL_RUN" docs/status.md docs/critical_todo.md docs/ai_todo.md`
    - Manual diff review confirming the refreshed docs still name the native Windows PASS artifact as the remaining checked-in release blocker.
  - **Current blocker:** none, but it should follow the next real evidence update so the docs change once, not repeatedly.

## Notes

- The earlier AI-todo item about downloading and inspecting one successful Windows regression artifact bundle is already complete.
- The main backlog change in this pass is consolidation: native Windows evidence capture and release-gate closure now live in one evidence chain instead of two adjacent top-level items.
- No source-code changes were made in this maintenance pass.
