# AI TODO queue (active)

Autopilot executes the first unchecked **top-level** item (`- [ ]`).
Keep this file short, current, and evidence-driven.

Last reprioritized: 2026-03-09 03:18 UTC.

## Current evidence snapshot

- Repo promise: unattended Windows daily backup flow (`README.md`, `USER_TODO.md`, Task Scheduler guidance).
- Current evidence lives in `README.md`, `docs/ARCHITECTURE.md`, `docs/CONFIG.md`, `docs/TROUBLESHOOTING.md`, `USER_TODO.md`, and source files; `docs/status.md` and `docs/critical_todo.md` are currently absent.
- Highest engineering-risk findings from source review:
  - Headless-by-default runtime milestone is now landed in `src/OneClickBackup.ahk`, but Windows-side smoke verification is still pending before closure.
  - `src/Lib/Notify.ahk` passes the SMTP secret to PowerShell on the command line.
  - `src/Lib/Shell.ahk` waits for child-process completion before draining stdout/stderr, which is fragile for verbose `7z` / `rclone` runs.

## Prioritized open items

- [ ] **P0 — Make unattended runs non-interactive by default**
  - **Why now:** the repo has now landed the headless-by-default code path, but this remains the top open item until Windows-side smoke verification confirms scheduled/background behavior is actually clean.
  - **Deliverables:**
    - Remove modal UI from default CLI/scheduled execution paths.
    - If manual desktop feedback is still wanted, gate it behind an explicit `--interactive` flag or config option.
    - Document the resulting headless vs interactive behavior in `README.md` and `USER_TODO.md`.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckHeadlessDefault.ps1`
    - `powershell -NoProfile -Command "Select-String -Path src\OneClickBackup.ahk -Pattern 'MsgBox|interactive'"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.ini`
    - `powershell -NoProfile -Command "Get-Content logs\summary_$(Get-Date -Format yyyyMMdd).csv -Tail 1"`
  - **Progress (2026-03-09 03:18 UTC):**
    - Added `--interactive` CLI flag to `src/OneClickBackup.ahk` and switched default dry-run / no-files / success / failure paths to headless console+log behavior.
    - Reserved desktop dialogs for explicit manual runs only.
    - Updated `README.md` and `USER_TODO.md` so scheduled-task guidance stays headless by default.
    - Added `scripts/CheckHeadlessDefault.ps1` as a deterministic static guard for the default non-interactive behavior.
    - Still needs Windows-side smoke verification before this item should be considered fully closed.

- [ ] **P0 — Remove command-line secret exposure from the email notification path**
  - **Why now:** `src/Lib/Notify.ahk` currently builds a PowerShell command with `-Password <secret>` inline. That undermines the repo’s stated secret-handling posture even though logs try to redact it.
  - **Deliverables:**
    - Stop passing SMTP secrets via process arguments.
    - Move secret handoff to a safer boundary (env lookup inside PowerShell, stdin, or equivalent).
    - Preserve log usefulness without leaking secret values.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Notify.ahk,scripts\SendMail.ps1 -Pattern 'Password|passwordEnv'"`
    - `powershell -NoProfile -Command "Select-String -Path logs\backup_*.log -Pattern ' -Password |DAILY_SMTP_PASS' -ErrorAction SilentlyContinue"`
    - Email-enabled smoke/failure run completes without exposing the password in logs or process args.

- [ ] **P1 — Expand prereq validation from binary presence to operational readiness**
  - **Why now:** `scripts/CheckPrereqs.ps1` verifies tool/env presence, but it does not yet prove the configured watch directory exists, output/temp locations are writable, archive naming is valid, or the configured remote is reachable. Those are first-run failure modes.
  - **Deliverables:**
    - Extend prereq validation to cover watch/output/tmp paths, archive-name sanity, and remote readiness.
    - Add explicit fixture configs for at least one pass case and one fail case.
    - Keep the check safe (no real upload) and automation-friendly.
  - **Verification:**
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\CheckPrereqs.ps1 -Config config\app.sample.ini`
    - Failing fixture exits non-zero with a clear actionable error.
    - Passing fixture exits `0` and prints a compact readiness summary.

- [ ] **P1 — Replace `Shell.Exec` with a timeout-safe, output-safe process runner**
  - **Why now:** `src/Lib/Shell.ahk` waits for process completion before reading stdout/stderr. That is fragile for chatty child processes and makes hangs harder to diagnose.
  - **Deliverables:**
    - Drain stdout/stderr safely during execution or switch to a safer runner approach.
    - Add timeout handling and duration/error metadata for `7z`, `rclone`, and mail steps.
    - Ensure logs preserve stderr context without hanging the parent script.
  - **Verification:**
    - `powershell -NoProfile -Command "Select-String -Path src\Lib\Shell.ahk -Pattern 'timeout|StdOut|StdErr|duration'"`
    - Synthetic verbose-child test finishes without deadlock.
    - Real dry-run / upload failure paths still capture useful diagnostics.

- [ ] **P1 — Add deterministic Windows regression coverage for the primary pipeline**
  - **Why now:** current repo evidence is setup-heavy and user-guidance-heavy, but there is no durable regression harness proving the main path stays healthy across refactors.
  - **Deliverables:**
    - Add at least one deterministic smoke path for dry-run and one failure-path assertion for upload/email/zip errors.
    - Wire the checks into a Windows-oriented CI workflow or documented local test entrypoint.
    - Keep fixtures config-only and secret-free.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path .github\workflows"`
    - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1 -Config config\app.sample.ini`
    - Presence of a documented test command in `README.md` and/or workflow YAML.

- [ ] **P2 — Create explicit release-status docs (`docs/status.md` + `docs/critical_todo.md`)**
  - **Why now:** this maintenance pass was asked to review those files, but they do not exist yet. That makes release state and blocker tracking too implicit.
  - **Deliverables:**
    - Add `docs/status.md` for current repo state and recent verification evidence.
    - Add `docs/critical_todo.md` for true release/blocker items only.
    - Seed them from current evidence: unattended-mode blocker, secret-handling blocker, process-runner risk, and regression-gap risk.
  - **Verification:**
    - `powershell -NoProfile -Command "Test-Path docs\status.md; Test-Path docs\critical_todo.md"`
    - `powershell -NoProfile -Command "Select-String -Path docs\status.md,docs\critical_todo.md -Pattern 'unattended|secret|runner|regression'"`

## Notes

- Historical setup micro-guidance lives in `USER_TODO.md`; this file should stay focused on engineering-delta priorities.
- Deep-research rationale for this ordering is captured in `docs/deep_research_auto.md`.
