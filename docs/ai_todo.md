# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-09 05:49 UTC.

## Current evidence snapshot

- Docs reviewed this pass: `README.md`, `USER_TODO.md`, `docs/ARCHITECTURE.md`, `docs/CONFIG.md`, `docs/TROUBLESHOOTING.md`, `docs/ai_todo.md`, `docs/deep_research_auto.md`.
- `README.md` and `USER_TODO.md` now present the product as **headless by default** for scheduled/CLI runs, with `--interactive` reserved for manual desktop use.
- A dedicated Windows evidence capture entrypoint now exists at `scripts/CaptureHeadlessEvidence.ps1`, and durable proof is staged at `docs/headless_default_release_gate.md`; the capture flow can now also include `schtasks /Query` output via `-ScheduledTaskName`, but the gate still remains open until a real Windows run populates that evidence with PASS-grade output.
- `docs/status.md` and `docs/critical_todo.md` are still absent, so release state and blocker tracking remain implicit.
- Highest engineering-risk findings still standing from the current evidence set:
  - headless-by-default behavior appears landed, but there is still no captured Windows smoke evidence proving scheduled/background runs are clean end to end;
  - `src/Lib/Notify.ahk` still passes the SMTP secret into PowerShell on the command line;
  - `src/Lib/Shell.ahk` still looks like a fragile choke point for verbose child-process execution;
  - prereq validation is still stronger on binary presence than on actual operational readiness.

## Prioritized open items

- [ ] **P0 — Close the headless-default release gate with real Windows evidence**
  - **Why now:** the repo docs now claim scheduled/CLI runs are headless by default. That is good, but it should not be treated as fully done until a real Windows smoke run proves the default path stays non-interactive and leaves usable logs/summaries.
  - **Deliverables:**
    - Run the default non-interactive path on Windows for both dry-run and real-run scenarios.
    - Capture proof that no modal dialog blocks the run unless `--interactive` is explicitly passed.
    - Record the exact verification commands and observed evidence in durable repo docs once confirmed.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`
    - `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
    - Scheduled-task/manual check shows no blocking `MsgBox` behavior on the default path.

- [ ] **P0 — Remove command-line secret exposure from the email notification path**
  - **Why now:** runtime secret exposure is still the cleanest security/release blocker in the current architecture. Avoiding committed secrets is not enough if the SMTP password is still passed as a process argument.
  - **Deliverables:**
    - Stop passing SMTP secrets via PowerShell command-line parameters.
    - Move secret handoff to a safer boundary such as in-process environment lookup, stdin, or another non-argv path.
    - Preserve support-grade logs without leaking secret material.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Notify.ahk,scripts\SendMail.ps1 -Pattern 'Password|passwordEnv'"`
    - `powershell -NoProfile -Command "Select-String -Path logs\backup_*.log -Pattern ' -Password |DAILY_SMTP_PASS' -ErrorAction SilentlyContinue"`
    - Email-enabled smoke/failure run succeeds without password exposure in logs or process args.

- [ ] **P1 — Replace `Shell.Exec` with a timeout-safe, output-safe process runner**
  - **Why now:** once headless mode is the default, process-runner reliability becomes a first-class unattended-runtime risk. A backup tool that hangs on verbose `7z` or `rclone` output is still not operationally trustworthy.
  - **Deliverables:**
    - Drain stdout/stderr safely during execution or swap to a safer runner pattern.
    - Add timeout handling plus duration/error metadata for `7z`, `rclone`, and mail steps.
    - Preserve stderr context in logs without risking deadlock.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Shell.ahk -Pattern 'timeout|StdOut|StdErr|duration'"`
    - Synthetic verbose-child test completes without deadlock.
    - Real dry-run / upload-failure paths still produce actionable diagnostics.

- [ ] **P1 — Expand prereq validation from binary presence to operational readiness**
  - **Why now:** `scripts/CheckPrereqs.ps1` reduces setup friction, but it still does not prove the configured watch directory exists, output/temp paths are writable, archive naming is sane, or the configured remote is actually reachable. Those are common first-run failures.
  - **Deliverables:**
    - Extend prereq validation to cover watch/output/tmp paths, archive-name sanity, and remote readiness.
    - Add at least one passing fixture config and one failing fixture config.
    - Keep the check safe and non-destructive.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.sample.ini`
    - Failing fixture exits non-zero with a clear actionable error.
    - Passing fixture exits `0` and prints a compact readiness summary.

- [ ] **P1 — Add deterministic Windows regression coverage for the main pipeline**
  - **Why now:** the repo already has good setup guidance, but it still lacks durable regression evidence that the primary dry-run / archive / upload / notify flow survives refactors.
  - **Deliverables:**
    - Add at least one deterministic smoke path for dry-run.
    - Add at least one deterministic failure-path assertion for upload/email/zip errors.
    - Wire the checks into a Windows-oriented CI workflow or an explicitly documented local regression entrypoint.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.sample.ini`
    - `powershell -NoProfile -Command "Test-Path .github\workflows"`
    - README and/or workflow YAML documents a stable regression command.

- [ ] **P2 — Add explicit release-state docs (`docs/status.md` + `docs/critical_todo.md`) after runtime blockers are tightened**
  - **Why now:** this pass was asked to review those files, but they still do not exist. That makes release state and blocker ownership too implicit for future maintenance.
  - **Deliverables:**
    - Add `docs/status.md` for current repo state, recent evidence, and known limits.
    - Add `docs/critical_todo.md` for true release/blocker items only.
    - Seed both from live evidence, not from wish-list planning.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path docs\status.md,docs\critical_todo.md -Pattern 'headless|secret|runner|prereq|regression'"`

## Notes

- Historical setup micro-guidance belongs in `USER_TODO.md`; this file should stay focused on engineering-delta priorities.
- Biggest correction in this pass: **headless-by-default is no longer framed as a missing feature, but as a release gate that needs real Windows proof before closure**.
- Deep-research rationale remains in `docs/deep_research_auto.md` and still broadly matches this ordering.
