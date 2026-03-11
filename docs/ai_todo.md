# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 16:19 UTC.

## Current evidence snapshot

- Repo status for this maintenance pass is **clean**: `git status --short --branch` returned only `## master...origin/master`.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- Root `STATUS.md` is still stale for roadmap guidance: `Last triage: 2026-02-15 (UTC)` and its first top-level task is still installer packaging.
- The headless-default release gate is still **open**: `docs/headless_default_release_gate.md` remains `Status: **PENDING_REAL_RUN**` and requires native Windows execution.
- `src/Lib/Shell.ahk` is no longer the main blocker: it already has timeout handling, duration metadata, and file-backed stdout/stderr capture.
- The SMTP argv-secret issue is also no longer top priority: `src/Lib/Notify.ahk` now passes `-PasswordEnv`, and `scripts/SendMail.ps1` resolves the secret inside PowerShell.
- The biggest still-open engineering gaps visible from the repo are:
  - readiness validation still drifts between `scripts/CheckPrereqs.ps1` and `ValidatePrereqs(...)` in `src/OneClickBackup.ahk`
  - no `config/fixtures/*` configs exist for deterministic pass/fail validation
  - no canonical `scripts/Regression.ps1` or `.github/workflows/*` entrypoint exists
  - `scripts/VerifyNonInteractiveDefault.ps1` appears orphaned while `scripts/CheckHeadlessDefault.ps1` is the real canonical guard in docs and capture flow
- Because the first unchecked item is what autopilot will execute, the queue should start with the highest-impact repo work that is **unblocked here**, not with the native-Windows evidence task.

## Prioritized open items

- [ ] **P0 — Unify readiness validation across PowerShell preflight and AHK runtime**
  - **Why now:** this is the biggest correctness gap still visible in the repo. `CheckPrereqs.ps1` can pass while runtime validation still fails on watch-dir, tmp/out dirs, archive-name, remote, or email fields.
  - **Deliverables:**
    - Define one readiness contract shared by `scripts/CheckPrereqs.ps1` and `ValidatePrereqs(...)`.
    - Cover `paths.watchDir`, `paths.tmpDir`, `paths.outDir`, `zip.exe`, `zip.passwordEnv`, `zip.archiveName`, `rclone.exe`, `rclone.remote`, and email prerequisites when enabled.
    - Add fixture configs for at least one passing case and two failing cases.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.pass.ini`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.fail-watchdir.ini`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.fail-email.ini`
    - `AutoHotkey64.exe src\OneClickBackup.ahk --config config\fixtures\readiness.fail-watchdir.ini --dry-run`
    - PowerShell preflight and AHK runtime fail for the same reason with similarly actionable messaging.

- [ ] **P1 — Add fixture-backed regression entrypoint for headless, smoke, and failure paths**
  - **Why now:** useful checks exist, but there is still no single regression command that protects the documented happy path plus at least one deterministic failure path.
  - **Deliverables:**
    - Add `scripts/Regression.ps1` as the canonical local regression command.
    - Make it run the headless static guard, prereq/readiness checks, smoke test, and at least one deterministic failure assertion.
    - Optionally add `.github/workflows/windows.yml`, but the local regression command must exist even without CI.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
    - `powershell -NoProfile -Command "Test-Path scripts\Regression.ps1; Test-Path .github\workflows\windows.yml"`
    - `powershell -NoProfile -Command "Get-Content scripts\Regression.ps1 | Select-String -Pattern 'CheckHeadlessDefault|CheckPrereqs|SmokeTest|fixtures'"`

- [ ] **P1 — Collapse duplicate headless static guards onto one canonical script**
  - **Why now:** `scripts/CheckHeadlessDefault.ps1` is the real guard referenced by README, user docs, and evidence capture, while `scripts/VerifyNonInteractiveDefault.ps1` appears unused and invites drift.
  - **Deliverables:**
    - Keep one canonical static guard path.
    - Either delete `scripts/VerifyNonInteractiveDefault.ps1` or turn it into a thin wrapper around `scripts/CheckHeadlessDefault.ps1`.
    - Make README/docs/capture flow all point to the same script name.
  - **Verification:**
    - `grep -RIn "VerifyNonInteractiveDefault" .`
    - `grep -RIn "CheckHeadlessDefault" README.md USER_TODO.md docs scripts`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`

- [ ] **P1 — Close the headless-default release gate with native Windows evidence**
  - **Why now:** this is still the highest release-confidence blocker, but it sits below unblocked repo work because this session cannot execute native Windows binaries.
  - **Deliverables:**
    - Run the safe capture from native Windows PowerShell.
    - Run the PASS-grade capture after directly observing that default runs stay headless unless `--interactive` is passed.
    - Refresh `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and optional scheduler proof.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
  - **Current blocker:** this OpenClaw/WSL session cannot launch native Windows `powershell.exe`, `cmd.exe`, or `AutoHotkey64.exe`, so the final evidence run must happen in a native Windows terminal.

- [ ] **P2 — Canonicalize release-state docs after runtime blockers are nailed down**
  - **Why now:** the missing `docs/status.md` / `docs/critical_todo.md` and stale root `STATUS.md` still make it too easy for humans or agents to optimize for installer packaging before runtime confidence is actually closed.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for true blockers only.
    - Reconcile root `STATUS.md` so installer packaging is explicitly downstream of readiness, regression, and headless-proof work.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'readiness|regression|headless|installer'"`

## Notes

- The biggest correction in this pass is **removing stale blockers from the top of the queue**: `Shell.Exec` hardening and SMTP argv-secret cleanup are no longer the right first tasks based on current repo evidence.
- The new top item is readiness-validation unification because it is both high-impact and fully actionable from the repo.
- The native Windows evidence task remains top-tier, but not first, because this session cannot complete it directly.
- This maintenance pass intentionally stays within docs-only scope: `docs/ai_todo.md` and `docs/deep_research_auto.md`.