# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-09 12:16 UTC.

## Current evidence snapshot

- Repo status in this maintenance pass: `git status --short --branch` returned `## master...origin/master` with no local changes before this doc refresh.
- Docs reviewed this pass: `README.md`, `USER_TODO.md`, `docs/ARCHITECTURE.md`, `docs/CONFIG.md`, `docs/TROUBLESHOOTING.md`, `docs/deep_research_auto.md`, `docs/ai_todo.md`.
- `README.md` and `USER_TODO.md` now consistently present the product as **headless by default** for scheduled/CLI runs, with `--interactive` reserved for manual desktop use.
- Source still confirms that dialogs are only shown behind the interactive path: `src/OneClickBackup.ahk` routes user-facing dialogs through `MaybeShowDialog(...)`, which calls `MsgBox` only when `--interactive` is enabled.
- A dedicated Windows evidence capture entrypoint exists at `scripts/CaptureHeadlessEvidence.ps1`, and durable proof is staged at `docs/headless_default_release_gate.md`; the capture flow records runtime context, headless guard output, smoke-test output, summary tail, current-day backup-log tail, and optional `schtasks` evidence.
- The headless-default gate is still **open** because this WSL/OpenClaw session cannot launch native Windows `powershell.exe`, `cmd.exe`, or `AutoHotkey64.exe`; attempts fail before process start with `WSL ... UtilBindVsockAnyPort:307: socket failed 1`.
- Security blocker still stands: `src/Lib/Notify.ahk` passes the SMTP password into `scripts/SendMail.ps1` via `-Password ...`, so the secret is still crossing the process boundary in argv form.
- Reliability blocker still stands: `src/Lib/Shell.ahk` still waits for the child process to finish before draining `StdOut` / `StdErr`, which is a weak unattended-runner pattern for verbose tools like `7z`, `rclone`, and PowerShell mail helpers.
- `scripts/CheckPrereqs.ps1` still checks binary/env presence, but the current docs evidence does not show validation of watch-dir existence, temp/output writability, archive-name sanity, or remote reachability.
- `docs/status.md`, `docs/critical_todo.md`, and a visible `.github/workflows` regression surface are still absent.

## Prioritized open items

- [ ] **P0 — Close the headless-default release gate with real native Windows evidence**
  - **Why now:** the repo now documents headless-by-default behavior clearly enough that the remaining work is not wording — it is proof. Until a real Windows run confirms that scheduled/default execution stays non-interactive and leaves support-grade artifacts, the release claim is still conditional.
  - **Deliverables:**
    - Run the default non-interactive path on Windows for both dry-run and real-run scenarios.
    - Capture proof that no blocking dialog appears unless `--interactive` is explicitly passed.
    - Refresh `docs/headless_default_release_gate.md` with the exact commands and resulting evidence.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`
    - `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CaptureHeadlessEvidence.ps1 -Config config\app.ini -IncludeRealRun -ObservedDefaultRunHeadless -ObservedScheduledTaskHeadless`
    - Manual/scheduled observation confirms no blocking `MsgBox` on the default path.
  - **Current blocker:** this repo is mounted in WSL, but this automation session cannot cross the Windows process boundary. Required human action: open **Windows PowerShell** in `C:\CORE\daily-ops-packager` and run the capture command above (optionally append `-ScheduledTaskName "OneClickBackupDaily"` if that task exists).

- [ ] **P0 — Remove command-line SMTP secret exposure**
  - **Why now:** this is the clearest remaining security flaw in the documented runtime path. Avoiding committed secrets is not enough if the SMTP password is still passed through a child-process command line.
  - **Deliverables:**
    - Stop passing the SMTP password via PowerShell argv.
    - Move secret handoff to a safer boundary such as direct environment lookup, stdin, or another non-argv path.
    - Keep failure logs useful without leaking secret material.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Notify.ahk,scripts\SendMail.ps1 -Pattern 'Password|passwordEnv'"`
    - `powershell -NoProfile -Command "Select-String -Path logs\backup_*.log -Pattern ' -Password |DAILY_SMTP_PASS' -ErrorAction SilentlyContinue"`
    - Email-enabled smoke/failure run succeeds without password exposure in logs or process args.

- [ ] **P1 — Replace `Shell.Exec` with a timeout-safe, output-safe runner**
  - **Why now:** once default execution is supposed to be unattended, child-process handling becomes a core product-risk area. A noisy `7z`, `rclone`, or PowerShell step that can stall or lose diagnostics is still a release-quality problem.
  - **Deliverables:**
    - Drain stdout/stderr safely during execution, or swap to a safer runner pattern.
    - Add timeout handling plus duration/error metadata for `7z`, `rclone`, and mail steps.
    - Preserve stderr context in logs without risking deadlock.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Shell.ahk -Pattern 'timeout|StdOut|StdErr|duration'"`
    - Synthetic verbose-child test completes without deadlock.
    - Real dry-run and upload-failure paths still emit actionable diagnostics.

- [ ] **P1 — Expand prereq validation into an operational-readiness gate**
  - **Why now:** `scripts/CheckPrereqs.ps1` already helps with setup, but first-run failures will still slip through if the watch directory is wrong, temp/output locations are not writable, archive naming is broken, or the configured remote is unreachable.
  - **Deliverables:**
    - Extend prereq validation to cover watch/output/tmp paths, archive-name sanity, and remote readiness.
    - Add at least one passing fixture config and one failing fixture config.
    - Keep the check safe and non-destructive.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.sample.ini`
    - Failing fixture exits non-zero with a clear actionable error.
    - Passing fixture exits `0` with a compact readiness summary.

- [ ] **P1 — Add deterministic Windows regression coverage for the main pipeline**
  - **Why now:** the repo has decent setup and manual smoke guidance, but it still lacks a durable regression surface that proves the primary dry-run / archive / upload / notify paths survive refactors.
  - **Deliverables:**
    - Add at least one deterministic dry-run smoke path.
    - Add at least one deterministic failure-path assertion for upload/email/zip errors.
    - Wire the checks into a Windows-oriented CI workflow or a clearly documented local regression entrypoint.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.sample.ini`
    - `powershell -NoProfile -Command "Test-Path .github\workflows"`
    - README and/or workflow docs describe a stable regression command.

- [ ] **P2 — Add explicit release-state docs once runtime blockers are narrowed**
  - **Why now:** this maintenance pass was explicitly asked to review `docs/status.md` and `docs/critical_todo.md`, and the result is that both are still missing. That makes current release state and blocker ownership too implicit.
  - **Deliverables:**
    - Add `docs/status.md` for current repo state, recent evidence, and known limits.
    - Add `docs/critical_todo.md` for true release/blocker items only.
    - Seed both from live evidence, not from wish-list planning.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path docs\status.md,docs\critical_todo.md -Pattern 'headless|secret|runner|prereq|regression'"`

## Notes

- Historical setup micro-guidance belongs in `USER_TODO.md`; this file should stay focused on the next engineering deltas.
- The queue remains intentionally short: proof of unattended behavior first, then secret handling, then runner reliability, then readiness/regression, and only then explicit status docs.
- `docs/status.md` and `docs/critical_todo.md` were reviewed by absence in this pass; they were **not** created here because this maintenance scope is limited to `docs/ai_todo.md` (and optional `docs/deep_research_auto.md`).
- Deep-research rationale in `docs/deep_research_auto.md` still broadly matches this ordering.
