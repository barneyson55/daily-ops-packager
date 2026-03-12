# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-12 13:22 UTC.

## Current evidence snapshot

- Verified at the requested repo root: `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` all exist.
- `git status --short --branch` was clean before this docs-only refresh: `## master...origin/master`.
- `docs/headless_default_release_gate.md` still shows `Status: **PENDING_REAL_RUN**`.
- Live GitHub evidence now shows a successful Windows regression run: `22997394546` (`Windows regression`, `master`, `success`).
- The successful artifact bundle for run `22997394546` was downloaded and verified to contain:
  - `regression.log`
  - `regression-summary.md`
  - `workflow-context.txt`
- That artifact confirms the intended CI story now exists: static headless-default guard, fixture-backed prereq checks, and the safe default smoke path all ran on `windows-latest`.
- But the same downloaded `regression.log` still contains `This script requires AutoHotkey v2.0.` and `Current interpreter: AutoHotkey v1.1.36.02 Unicode 64-bit` before ending with `Regression suite OK.`
- Consequence: the CI pipeline is green, but it may still permit a wrong-interpreter false positive. That is now the highest-leverage engineering issue before treating CI as strong release evidence.
- `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` still describe the older failure/zero-artifact state, so those status surfaces are stale relative to the live repo evidence.

## Queueing rule for this file

- Lead with the next highest-leverage item supported by fresh evidence.
- Prefer dependency order over static severity: first make the CI proof trustworthy, then close the native Windows release gate, then reconcile stale status surfaces.
- Keep the top-level open queue short (target 3-7 items).

## Closed out of the queue in this pass

- [x] Verify that `docs/status.md`, `docs/critical_todo.md`, `docs/ai_todo.md`, and `docs/deep_research_auto.md` exist.
- [x] Download one successful Windows regression artifact bundle and verify the expected file set.
  - Verified from run `22997394546`.
  - Verified files: `regression.log`, `regression-summary.md`, `workflow-context.txt`.

## Prioritized open items

- [ ] **P0 — Harden Windows regression so a wrong AutoHotkey major version cannot pass green**
  - **Why first:** the repo now has a green CI run, but the downloaded artifact still shows the AutoHotkey v2-required banner and a v1 interpreter string while the suite reports success. Until that is fixed, CI evidence can overstate release confidence.
  - **Deliverables:**
    - Make the workflow / smoke path resolve an explicit AutoHotkey v2 executable instead of tolerating ambiguous `AutoHotkey.exe` discovery.
    - Make `scripts\SmokeTest.ps1` and/or `scripts\Regression.ps1` fail if the smoke run emits `This script requires AutoHotkey v2.0.` or `Current interpreter: AutoHotkey v1`.
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

- [ ] **P1 — Run native Windows headless-evidence capture, including scheduler audit if `OneClickBackupDaily` exists**
  - **Why second:** once CI is trustworthy, the next missing proof is still direct observation on a native Windows desktop.
  - **Deliverables:**
    - Run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal.
    - If `OneClickBackupDaily` exists, rerun with `-ScheduledTaskName "OneClickBackupDaily"` so the same artifact captures scheduler-query output and task-action audit evidence.
    - Preserve the newest `logs\headless_release_gate_*.log` transcript.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -Command "Get-ChildItem logs\headless_release_gate_*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1 FullName,LastWriteTime"`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'OneClickBackupDaily|schtasks|--interactive|OneClickBackup.ahk'"`
  - **Current blocker:** requires a native Windows terminal; this WSL/OpenClaw session cannot perform the observed run.

- [ ] **P0 — Close `docs/headless_default_release_gate.md` with PASS-grade native Windows evidence**
  - **Why third:** this is still the checked-in release blocker even after CI recovery.
  - **Deliverables:**
    - Rerun the wrapper in `-Mode Pass -ObservedBy "YourName"` after directly observing headless-by-default behavior on a native Windows desktop.
    - Ensure `docs\headless_default_release_gate.md` flips from `PENDING_REAL_RUN` to `PASS`.
    - Validate the final artifact with the repo assertion script.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - `powershell -NoProfile -Command "Select-String -Path docs\headless_default_release_gate.md -Pattern 'Status: \*\*PASS\*\*|Observed by:'"`
  - **Current blocker:** requires real Windows observation and cannot be closed from this environment.

- [ ] **P1 — Reconcile stale status surfaces immediately after the next fresh evidence lands**
  - **Why last:** the repo now has live CI success and artifact verification, but the status docs outside this file still describe the earlier failing/zero-artifact state. They should be refreshed right after the next evidence-backed change, not via broad doc churn first.
  - **Deliverables:**
    - Update `STATUS.md`, `docs/status.md`, and `docs/critical_todo.md` so they stop claiming the latest workflow runs are only failures or that the repo has zero stored artifacts.
    - Keep the docs explicit that CI artifact success does **not** replace the native Windows PASS gate.
    - Record the most recent evidence timestamps/run ids when the docs are refreshed.
  - **Verification:**
    - `grep -n "08:29 UTC\|workflow file issue\|total_count.:0\|only failed runs\|PENDING_REAL_RUN" STATUS.md docs/status.md docs/critical_todo.md docs/ai_todo.md`
    - Manual diff review across the four status surfaces.
  - **Current blocker:** none, but it should follow fresh evidence and stay tightly scoped.

## Notes

- The earlier top item (download/inspect a successful artifact bundle) is now done and should stay closed unless the artifact contract changes.
- The native Windows PASS artifact remains the actual release blocker.
- No source-code changes were made in this maintenance pass.
