# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 16:02 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath: `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only pass: `## master...origin/master`.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`.
- The latest successful `windows-regression.yml` run is still `22997394546`, and its downloaded artifact bundle contains the intended review files:
  - `regression.log`
  - `regression-summary.md`
  - `workflow-context.txt`
- But that same green `regression.log` still contains `This script requires AutoHotkey v2.0.` and `Current interpreter: AutoHotkey v1.1.36.02 Unicode 64-bit` before ending with `Regression suite OK.`
- Two newer workflow attempts then failed before the regression suite could complete:
  - `23006791388`
  - `23010206186`
- The newest failure log (`23010206186`) lists installed v2 paths including `C:\Program Files\AutoHotkey\v2\AutoHotkey.exe` and `AutoHotkey64.exe`, then still throws `AutoHotkey v2 executable not found after Chocolatey install.`
- GitHub Actions artifacts are now definitely present (`gh api repos/barneyson55/daily-ops-packager/actions/artifacts` returned `total_count: 8` in this pass), but the newest failed-run artifact only contains `regression-summary.md` and `workflow-context.txt`, with `outcome=skipped` and no `regression.log`.
- Consequence: the highest-impact work is now restoring a trustworthy green Windows regression after the AutoHotkey v2 discovery breakage, then proving that green run is not a wrong-runtime false positive, then closing the native Windows release gate.
- `docs/status.md` and `docs/critical_todo.md` are stale relative to live evidence because they still describe the older `only failures` / `0 artifacts` state.

## Queueing rule for this file

- Restore trustworthy CI before doc sync.
- Keep only 3-7 concrete open items.
- Each item must end with a check that can clearly pass or fail.

## Prioritized open items

- [ ] **P0 — Repair AutoHotkey v2 discovery so `windows-regression.yml` reaches `scripts\Regression.ps1` again**
  - **Why first:** the two newest workflow attempts fail in the install/discovery stage, so there is no fresh regression evidence to trust or inspect.
  - **Deliverables:**
    - Fix the workflow install/discovery logic so it accepts the actual installed v2 executable paths already shown in the runner log (`C:\Program Files\AutoHotkey\v2\AutoHotkey.exe` and/or `AutoHotkey64.exe`) instead of throwing `AutoHotkey v2 executable not found after Chocolatey install.`
    - Publish one new successful `windows-regression.yml` run after that repair.
    - Ensure the downloaded artifact bundle for that run includes `regression.log`, not just summary/context files.
  - **Verification:**
    - `gh run view <new-success-run> --log-failed`
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `find tmp/windows-regression-artifact -name regression.log -print | grep regression.log`
  - **Current blocker:** requires workflow/source changes plus a fresh GitHub Actions run; cannot be closed in this docs-only pass.

- [ ] **P0 — Keep the repaired Windows regression green only when AutoHotkey v2 actually runs**
  - **Why second:** the last green run (`22997394546`) still looks like a likely false positive because its artifact log contains wrong-runtime strings.
  - **Deliverables:**
    - Keep the smoke/regression path on an explicit AutoHotkey v2 executable.
    - Make the workflow fail if output contains `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
    - Publish one new successful `windows-regression.yml` artifact whose `regression.log` is free of those strings and still ends with `Regression suite OK.`
  - **Verification:**
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `python3 - <<'PY'
from pathlib import Path
p = next(Path('tmp/windows-regression-artifact').glob('**/regression.log'))
raw = p.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** depends on the preceding CI repair and a fresh successful run; cannot be closed in this docs-only pass.

- [ ] **P0 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why third:** even with trustworthy CI, the checked-in release blocker remains direct native-Windows observation that the default path stays headless unless `--interactive` is passed.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so the artifact captures scheduler-query output and task-action audit evidence.
    - Rerun in `-Mode Pass -ObservedBy "YourName"`, preserve the newest `logs\headless_release_gate_*.log`, and update `docs\headless_default_release_gate.md` from `PENDING_REAL_RUN` to `PASS`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:|OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal plus human desktop observation; cannot be closed from this WSL/OpenClaw session.

- [ ] **P1 — Refresh stale status docs immediately after the next evidence-bearing change lands**
  - **Why last:** `docs/status.md` and `docs/critical_todo.md` are behind live repo evidence, but updating them before the next CI/native evidence change would create avoidable churn.
  - **Deliverables:**
    - Update `docs/status.md` and `docs/critical_todo.md` so they stop claiming the repo only has failed workflow runs or zero stored artifacts.
    - Record the newest run ids and timestamps used for the refresh, including the failed follow-up runs after `22997394546` if they remain relevant context.
    - Keep the docs explicit that green CI artifact verification still does **not** replace the native Windows PASS gate.
  - **Verification:**
    - `grep -n "only failure\|only failures\|zero stored artifacts\|total_count.:0" docs/status.md docs/critical_todo.md docs/ai_todo.md`
    - Manual diff review confirming the refreshed docs still name the native Windows PASS artifact as the remaining checked-in release blocker.
  - **Current blocker:** none, but it should follow the next real evidence update so the docs change once, not repeatedly.

## Notes

- The earlier AI-todo item about downloading and inspecting one successful Windows regression artifact bundle remains complete.
- The main backlog change in this pass is that CI repair is now split into two concrete milestones: first restore AutoHotkey v2 discovery, then prove the restored green run is not a wrong-runtime false positive.
- No source-code changes were made in this maintenance pass.
