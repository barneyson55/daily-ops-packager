# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-11 15:13 UTC.

## Current evidence snapshot

- Repo status in this maintenance pass is **dirty**: `git status --short --branch` showed `## master...origin/master` plus tracked changes in `README.md`, `USER_TODO.md`, `docs/ai_todo.md`, `docs/deep_research_auto.md`, `docs/headless_default_release_gate.md`, `scripts/CaptureHeadlessEvidence.ps1`, `scripts/RunHeadlessEvidenceCapture.ps1`, `scripts/SendMail.ps1`, and `src/Lib/Notify.ahk`, plus untracked `scripts/AssertHeadlessReleaseGate.ps1` and local OpenClaw workspace files.
- Docs existence check for this pass:
  - `docs/status.md` → **missing**
  - `docs/critical_todo.md` → **missing**
  - `docs/ai_todo.md` → **present**
  - `docs/deep_research_auto.md` → **present**
- Root `STATUS.md` is still stale for roadmap guidance: `Last triage: 2026-02-15 (UTC)` and its first top-level task is still installer packaging.
- The headless-default proof surface is stronger than before: `scripts/CheckHeadlessDefault.ps1`, `scripts/CaptureHeadlessEvidence.ps1`, `scripts/RunHeadlessEvidenceCapture.ps1`, and the new `scripts/AssertHeadlessReleaseGate.ps1` together cover static checks plus durable evidence capture.
- The headless-default release gate is still **open** because this WSL/OpenClaw session cannot launch native Windows `powershell.exe`, `cmd.exe`, or `AutoHotkey64.exe`; attempts fail before process start with `WSL ... UtilBindVsockAnyPort:307: socket failed 1`.
- The previous SMTP argv-secret blocker remains **demoted, not deleted**: current working-tree evidence shows `src/Lib/Notify.ahk` now passes `-PasswordEnv`, and `scripts/SendMail.ps1` resolves the secret inside PowerShell, but those changes are not yet committed.
- The largest fully actionable engineering gaps remain:
  - `src/Lib/Shell.ahk` still waits for process completion before draining `StdOut` / `StdErr`, with no timeout or duration metadata.
  - readiness validation is still split between runtime `ValidatePrereqs(...)` and `scripts/CheckPrereqs.ps1`.
  - regression coverage is still fragmented (`scripts/SmokeTest.ps1` exists, `.github/workflows` is absent, and `scripts/VerifyNonInteractiveDefault.ps1` is still not the canonical guard path).
- Because the first unchecked item is what autopilot will execute, **externally blocked work should not sit above unblocked engineering work**.

## Prioritized open items

- [ ] **P0 — Replace `Shell.Exec` with an unattended-safe process runner**
  - **Why now:** this is the highest-impact runtime risk that is still fully actionable from the repo. `7z`, `rclone`, and PowerShell mail all depend on it.
  - **Deliverables:**
    - Drain stdout/stderr safely during execution, or replace the runner with a safer pattern.
    - Add timeout handling plus duration/exit metadata.
    - Preserve actionable stderr in logs without deadlock risk.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Shell.ahk -Pattern 'timeout|StdOut|StdErr|duration'"`
    - A synthetic verbose-child test completes without hanging.
    - Dry-run plus at least one forced failure path still emit useful diagnostics.

- [ ] **P1 — Unify prereq/readiness validation so setup checks match runtime behavior**
  - **Why now:** a user can still get a green prereq check and then fail immediately at runtime on watch-dir, tmp/out, archive-name, or remote issues.
  - **Deliverables:**
    - Define one shared readiness contract for PowerShell preflight and AHK runtime.
    - Cover watch-dir existence, tmp/out writability, archive-name sanity, `rclone.remote` readiness, and optional email prerequisites.
    - Add at least one passing fixture config and one failing fixture config.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.pass.ini`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\fixtures\readiness.fail-watchdir.ini`
    - `AutoHotkey64.exe src\OneClickBackup.ahk --config config\fixtures\readiness.fail-watchdir.ini --dry-run`
    - The prereq script and runtime fail for the same reason with similarly actionable messaging.

- [ ] **P1 — Add one canonical Windows regression entrypoint for headless + smoke + failure paths**
  - **Why now:** the repo has useful checks, but still no single regression command that protects headless behavior, dry-run, and common failure cases from refactors.
  - **Deliverables:**
    - Create one canonical local regression command and/or Windows CI workflow.
    - Include the headless guard, smoke test, and at least one deterministic failure-path assertion for zip/upload/email.
    - Either remove `scripts/VerifyNonInteractiveDefault.ps1` or wire it into the canonical regression surface so the static checks do not drift.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\Regression.ps1`
    - `powershell -NoProfile -Command "Test-Path .github\workflows\windows.yml; Test-Path scripts\Regression.ps1"`
    - README and/or workflow docs describe the same stable regression command.

- [ ] **P1 — Close the headless-default release gate with real native Windows evidence**
  - **Why now:** this is still the highest external release-confidence blocker, but it is intentionally below the unblocked code-side work because this session cannot execute it.
  - **Deliverables:**
    - Run the default non-interactive path on Windows for both safe/smoke and real-run scenarios.
    - Capture proof that no blocking dialog appears unless `--interactive` is explicitly passed.
    - Refresh `docs/headless_default_release_gate.md` to `Status: **PASS**` with observer attribution and optional scheduler evidence.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`
    - `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\AssertHeadlessReleaseGate.ps1 -Path docs\headless_default_release_gate.md`
    - Optional scheduler proof: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\RunHeadlessEvidenceCapture.ps1 -Mode Pass -ObservedBy "YourName" -ScheduledTaskName "OneClickBackupDaily"`
  - **Current blocker:** this automation session cannot cross the Windows process boundary. Required human action: open **Windows PowerShell** in `C:\CORE\daily-ops-packager`, run the safe capture first, then the PASS-grade capture if the configured upload/email target is safe for a real run.

- [ ] **P2 — Canonicalize release-state docs and retire stale planning drift**
  - **Why now:** `docs/ai_todo.md` and `docs/deep_research_auto.md` are now more truthful than root `STATUS.md`, but `docs/status.md` and `docs/critical_todo.md` still do not exist.
  - **Deliverables:**
    - Add `docs/status.md` for current state, evidence, and known limits.
    - Add `docs/critical_todo.md` for real blockers only.
    - Reconcile root `STATUS.md` so installer packaging stays explicitly downstream of runtime hardening.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path STATUS.md,docs\status.md,docs\critical_todo.md -Pattern 'headless|runner|readiness|regression|installer'"`

## Notes

- The biggest prioritization correction in this pass is **moving the blocked Windows-evidence item below the highest-impact repo work that can actually be done from here**.
- The mail-secret issue stays in the risk bucket rather than the active top queue because current working-tree evidence already points toward the right implementation (`-PasswordEnv`). If those uncommitted changes are dropped, command-line secret exposure becomes urgent again.
- Root `STATUS.md`, `README.md`, `USER_TODO.md`, and `docs/headless_default_release_gate.md` were reviewed as evidence sources only. This maintenance scope remains limited to `docs/ai_todo.md` and optionally `docs/deep_research_auto.md`.
