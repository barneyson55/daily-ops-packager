# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 23:06 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean during this docs-only maintenance pass: `## master...origin/master`.
- Fresh GitHub Actions evidence shows the newest `windows-regression.yml` runs are:
  - `23018180172` — success
  - `23014208204` — success
  - older failures are still visible in history, but they are no longer the current lead story.
- `gh api repos/barneyson55/daily-ops-packager/actions/artifacts` now reports `total_count: 10`, including stored artifacts for both fresh success runs.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the checked-in native Windows release proof is still missing.
- `docs/status.md` and `docs/critical_todo.md` are now materially stale because they still describe the older `only failures` / `0 artifacts` state.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Do **not** leave a native-Windows-only or human-observation-only task in slot 1 while an agent-actionable repo task is still open.
- Every item must end with a clear verification block that can pass or fail.
- Keep blocked external work visible, but mark the blocker explicitly.

## Prioritized open items

- [ ] **P0 — Harden `windows-regression.yml` so wrong AutoHotkey runtime evidence cannot produce a green run**
  - **Why this is first:** it is the highest-leverage task that remains actionable from normal repo automation. The newest green artifacts look correct, but today that confidence still depends on after-the-fact log inspection instead of workflow-enforced assertions.
  - **Deliverables:**
    - Keep resolving an explicit AutoHotkey v2 executable before running regression.
    - Fail the workflow if `regression.log` contains `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
    - Fail the workflow if `regression.log` stops showing the explicit resolved-v2 executable line.
    - Publish one new successful `windows-regression.yml` run whose downloaded artifact still passes those assertions.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh run download <new-success-run> --dir tmp/windows-regression-artifact`
    - `python3 - <<'PY'
from pathlib import Path
p = next(Path('tmp/windows-regression-artifact').glob('**/regression.log'))
raw = p.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Resolved AutoHotkey v2 executable:' in text
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** requires workflow/source changes plus one fresh GitHub Actions run, but it is **not** blocked on native Windows desktop observation.

- [ ] **P1 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is second:** this is still the checked-in release blocker, but it is not continuously actionable from this WSL/OpenClaw session and should not occupy the autopilot slot-1 position while repo-change work remains.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so scheduler-query output and task-action audit evidence land in the same artifact.
    - Rerun in `-Mode Pass -ObservedBy "YourName"`, preserve the newest `logs\headless_release_gate_*.log`, and update `docs\headless_default_release_gate.md` from `PENDING_REAL_RUN` to `PASS`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:|OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal plus human desktop observation; cannot be closed from this WSL/OpenClaw session.

- [ ] **P2 — Refresh `docs/status.md` and `docs/critical_todo.md` so operator docs match the restored green-run/artifact reality without overstating CI**
  - **Why this is third:** those docs are currently inaccurate and can mislead triage, but they still trail regression hardening and native-proof capture in engineering leverage.
  - **Deliverables:**
    - Remove the stale `only failures` / `0 artifacts` framing.
    - Cite the fresh success runs (`23018180172`, `23014208204`) and the artifact story they actually published.
    - Keep the docs explicit that green CI artifacts improve regression confidence but do **not** replace native Windows PASS evidence unless P1 has closed.
  - **Verification:**
    - `grep -n "only failure\|only failures\|0 artifacts\|zero stored Actions artifacts\|total_count.:0" docs/status.md docs/critical_todo.md`
    - `grep -n "23018180172\|23014208204\|regression.log\|workflow-context.txt" docs/status.md docs/critical_todo.md`
    - Manual diff review confirming native Windows PASS evidence remains the checked-in release blocker until P1 is complete.
  - **Current blocker:** none.

## Notes

- The biggest queue fix in this pass is **actionability**: the release blocker remains visible, but the first item is now something repo automation can actually execute.
- The repo is no longer in a `CI broken / no artifacts` state. The current shape is: **green CI exists**, **workflow hardening still matters**, and **native Windows PASS evidence is still missing**.
- No source-code changes were made in this maintenance pass.
