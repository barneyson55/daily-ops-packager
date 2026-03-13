# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-13 00:32 UTC.

## Current evidence snapshot

- Verified at the exact requested repo root `/home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager` (realpath resolves to `/mnt/c/CORE/daily-ops-packager`): `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git -C /home/node/.openclaw/workspace/projects/auto-senior-pm/repos/daily-ops-packager status --short --branch` was clean at the start of this docs-only maintenance pass: `## master...origin/master`.
- Fresh `gh run list --workflow windows-regression.yml --limit 8` now shows a **mixed** CI picture rather than either "all broken" or "all green":
  - `23029500849` — failure
  - `23018180172` — success
  - `23014208204` — success
  - older failures remain in history (`23010206186`, `23006791388`).
- `gh api repos/barneyson55/daily-ops-packager/actions/artifacts` currently reports `total_count: 11`, so Actions artifacts do exist and are still being uploaded.
- Downloaded artifact evidence shows a new split story:
  - Run `23018180172` artifact contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
  - Its decoded `regression.log` includes `Resolved AutoHotkey v2 executable:` and `Regression suite OK.` and does **not** include `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
  - Run `23029500849` artifact contains only `regression-summary.md` and `workflow-context.txt`; it does **not** contain `regression.log`.
  - That failed run’s summary says `Outcome: skipped` while still claiming `scripts\Regression.ps1` ran and the prereq/smoke assertions were proven, which is currently misleading.
- `.github/workflows/windows-regression.yml` already contains runtime-log assertions inside the `Run regression suite` step for:
  - required: `Resolved AutoHotkey v2 executable:`
  - forbidden: `This script requires AutoHotkey v2.0.`, `Current interpreter: AutoHotkey v1`, and generic `AutoHotkey v1`
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`, so the checked-in native Windows release proof is still missing.
- `docs/status.md` and `docs/critical_todo.md` are now materially stale because they still describe the older `only failures` / `0 artifacts` state and do not mention the newer mixed-result artifact story.

## Queueing rules for this file

- Keep only 3-7 concrete open items.
- Order by **highest engineering impact that is still actionable**.
- Do **not** leave a native-Windows-only or human-observation-only task in slot 1 while an agent-actionable repo task is still open.
- Every item must end with a clear verification block that can pass or fail.
- Keep blocked external work visible, but mark the blocker explicitly.

## Prioritized open items

- [ ] **P0 — Make `windows-regression.yml` failure artifacts truthful and complete when regression never starts**
  - **Why this is first:** the newest failure (`23029500849`) shows the current workflow can upload an artifact bundle that looks authoritative while omitting `regression.log` and overstating what was actually proven. That is higher-impact than rechecking the already-guarded AutoHotkey runtime path.
  - **Deliverables:**
    - If setup fails before `Run regression suite`, publish an explicit pre-regression failure marker (for example `pre-regression-failure.txt`) and make `regression-summary.md` say the regression step did **not** run.
    - Do **not** claim prereq checks or smoke-path execution were proven unless `regression.log` exists from an actual regression step execution.
    - Preserve the current success-path artifact bundle (`regression.log`, `regression-summary.md`, `workflow-context.txt`) for genuine green runs.
  - **Verification:**
    - `gh run download <new-run> --dir tmp/windows-regression-artifact`
    - `find tmp/windows-regression-artifact -maxdepth 3 -type f | sort`
    - If the downloaded artifact lacks `regression.log`, then:
      - `grep -n "Outcome: skipped\|Outcome: failure" tmp/windows-regression-artifact/**/regression-summary.md`
      - `grep -n "did not run\|pre-regression" tmp/windows-regression-artifact/**/regression-summary.md tmp/windows-regression-artifact/**/workflow-context.txt tmp/windows-regression-artifact/**/pre-regression-failure.txt`
      - `! grep -n "Fixture-backed prereq checks passed\|safe smoke path was exercised\|scripts\\Regression.ps1 ran" tmp/windows-regression-artifact/**/regression-summary.md`
    - If the downloaded artifact includes `regression.log`, the summary may only claim proof points consistent with a real regression execution.
  - **Current blocker:** requires workflow/source changes plus one fresh Actions run, but it is **not** blocked on native Windows desktop observation.

- [ ] **P1 — Re-establish one fresh green `windows-regression.yml` run after P0 and verify the full artifact bundle still proves the AutoHotkey v2 path**
  - **Why this is second:** once P0 stops misleading skipped-run artifacts, the next highest-value step is a fresh successful run proving the workflow still produces the expected durable evidence on the happy path.
  - **Deliverables:**
    - Land a workflow revision that keeps the successful artifact bundle complete.
    - Publish one new successful `windows-regression.yml` run after that revision.
    - Confirm the downloaded artifact still contains `regression.log`, `regression-summary.md`, and `workflow-context.txt`.
    - Confirm `regression.log` still shows the explicit resolved AutoHotkey v2 line and still excludes the v1/runtime-mismatch text.
  - **Verification:**
    - `gh run list --workflow windows-regression.yml --limit 5`
    - `gh run download <new-success-run> --dir tmp/windows-regression-success`
    - `python3 - <<'PY'
from pathlib import Path
base = Path('tmp/windows-regression-success')
log = next(base.glob('**/regression.log'))
summary = next(base.glob('**/regression-summary.md'))
ctx = next(base.glob('**/workflow-context.txt'))
assert log.is_file() and summary.is_file() and ctx.is_file()
raw = log.read_bytes()
text = raw.decode('utf-16le', errors='ignore') if b'\x00' in raw else raw.decode('utf-8', errors='ignore')
assert 'Resolved AutoHotkey v2 executable:' in text
assert 'Regression suite OK.' in text
assert 'This script requires AutoHotkey v2.0.' not in text
assert 'Current interpreter: AutoHotkey v1' not in text
PY`
  - **Current blocker:** depends on P0 plus one fresh successful Actions run.

- [ ] **P2 — Capture and commit PASS-grade native Windows headless-default evidence, including scheduler audit when `OneClickBackupDaily` exists**
  - **Why this is third:** this is still the checked-in release blocker, but it is not continuously actionable from this WSL/OpenClaw session and should stay behind agent-actionable repo work.
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

- [ ] **P3 — Refresh `docs/status.md` and `docs/critical_todo.md` so operator docs match the current mixed CI/artifact reality without overstating CI**
  - **Why this is fourth:** the docs are inaccurate today, but fixing the underlying workflow evidence shape is still higher leverage than documenting the broken summary behavior as-is.
  - **Deliverables:**
    - Remove the stale `only failures` / `0 artifacts` framing.
    - Cite the current mixed state: latest failure `23029500849`, recent successes `23018180172` and `23014208204`, and `actions/artifacts total_count: 11`.
    - Explicitly note that the newest failed-run artifact is incomplete/misleading because it lacks `regression.log` and says `Outcome: skipped`.
    - Keep the docs explicit that green CI artifacts improve regression confidence but do **not** replace native Windows PASS evidence unless P2 has closed.
  - **Verification:**
    - `grep -n "only failure\|only failures\|0 artifacts\|zero stored Actions artifacts\|total_count.:0" docs/status.md docs/critical_todo.md`
    - `grep -n "23029500849\|23018180172\|23014208204\|Outcome: skipped\|regression.log\|workflow-context.txt\|total_count: 11" docs/status.md docs/critical_todo.md`
    - Manual diff review confirming native Windows PASS evidence remains the checked-in release blocker until P2 is complete.
  - **Current blocker:** none.

## Notes

- The biggest queue fix in this pass is **changing the lead problem statement**: the workflow already asserts the AutoHotkey runtime during the regression step, so the main open CI gap is now **truthful artifacting when the run fails before that step executes**.
- The repo is not in a simple `CI broken / no artifacts` state and not in a simple `CI green / all good` state either. The current shape is: **recent green artifacts exist**, **a newer failed run produced an incomplete/misleading artifact**, and **native Windows PASS evidence is still missing**.
- No source-code changes were made in this maintenance pass.
