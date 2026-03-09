# Deep Research — daily-ops-packager

Updated: 2026-03-09 03:18 UTC
Scope of this pass: local evidence first, minimal external validation second. No code changes in this maintenance pass.

## Sources reviewed

### Local repo evidence
- `README.md`
- `docs/ARCHITECTURE.md`
- `docs/CONFIG.md`
- `docs/TROUBLESHOOTING.md`
- `docs/ai_todo.md` (pre-refresh scaffold)
- `USER_TODO.md`
- `config/app.sample.ini`
- `src/OneClickBackup.ahk`
- `src/Lib/Config.ahk`
- `src/Lib/FileCollector.ahk`
- `src/Lib/ZipPack.ahk`
- `src/Lib/RcloneUpload.ahk`
- `src/Lib/Notify.ahk`
- `src/Lib/Report.ahk`
- `src/Lib/Shell.ahk`
- `scripts/CheckPrereqs.ps1`
- `scripts/Init-Config.ps1`
- `scripts/SmokeTest.ps1`
- absence checks for common `.github/workflows/*.yml` entrypoints and for `docs/status.md` / `docs/critical_todo.md`

### Minimal external validation
- rclone official docs: `https://rclone.org/commands/rclone_copy/`
  - confirms `rclone copy` copies without deleting destination files
- Microsoft docs: `https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create`
  - confirms Task Scheduler / `schtasks` is a first-class scheduled-execution surface for this Windows workflow

## Architecture snapshot

This repo is not a general backup platform yet; it is a focused single-user Windows automation pipeline:

1. load INI config
2. validate tool paths + secrets
3. collect files modified today
4. copy to temp workspace preserving relative paths
5. archive with 7-Zip
6. optionally verify archive
7. upload with rclone
8. optionally send email
9. append summary CSV + write logs

That narrow scope is good. The problem is not over-ambition; it is productization maturity around unattended execution and regression confidence.

## What the repo already does well

- Clear, simple pipeline boundaries in source and docs.
- Strong baseline principle: source files are never mutated.
- Failure artifacts are intentionally kept for inspection.
- Secrets are not stored in config files.
- Summary CSV gives a compact operational ledger.
- Setup guidance for first-time Windows users is already extensive.

## Highest-impact findings from repo evidence

### 1) The product promise is unattended automation, but runtime behavior is still desktop-interactive

Evidence:
- `README.md` and `USER_TODO.md` explicitly steer users toward Task Scheduler daily automation.
- `src/OneClickBackup.ahk` calls `MsgBox` on dry-run, no-files, success, and failure paths.

Implication:
- This is a release-gate mismatch. Scheduled automation should succeed or fail cleanly without requiring a human to dismiss a dialog.

Roadmap consequence:
- Headless behavior must outrank CI polish and doc cleanup.

### 2) Secret posture is good at the config layer but weak at the process-boundary layer

Evidence:
- Docs correctly say secrets belong in environment variables.
- `src/Lib/Notify.ahk` still builds a PowerShell command line containing the SMTP password.
- `scripts/SendMail.ps1` accepts the password as a plain string parameter.

Implication:
- The repo avoids committing secrets, but still risks exposing them at runtime through process arguments or support captures.

Roadmap consequence:
- Secret-boundary hardening is a P0/P1 engineering item, not a later cleanup.

### 3) The current process runner is a likely reliability bottleneck

Evidence:
- `src/Lib/Shell.ahk` waits for process completion before draining stdout/stderr.
- `ZipPack`, `RcloneUpload`, and `Notify` all depend on this runner.

Implication:
- Verbose child processes can become harder to diagnose and, in some process-host combinations, can stall the pipeline.

Roadmap consequence:
- Improve the runner before scaling release confidence or adding richer notifications.

### 4) The repo has lots of setup detail, but not enough durable engineering evidence surfaces

Evidence:
- `USER_TODO.md` is rich and operationally useful.
- `docs/status.md` and `docs/critical_todo.md` are missing.
- The previous `docs/ai_todo.md` was mostly historical sweep logging rather than an active engineering queue.

Implication:
- Setup help exists, but current blocker state is implicit and spread across files.

Roadmap consequence:
- Add explicit status/blocker docs after the top runtime issues are isolated.

### 5) `CheckPrereqs.ps1` is useful but still underpowered for first-run success

Evidence:
- It checks existence of `7z`, `rclone`, and required env vars.
- It does not yet validate watch directory existence, output/tmp writability, archive naming sanity, or remote readiness.

Implication:
- A user can pass prereqs and still fail immediately on first real run.

Roadmap consequence:
- Operational-readiness validation should become a real gate, not just a binary-presence check.

## External validation and why it matters

### rclone copy semantics
Official `rclone copy` docs state that copy does **not** delete files from the destination.

Why this matters here:
- The current product behavior is additive backup, not source/destination mirroring.
- That is consistent with the repo’s safety posture, but it also means retention/cleanup expectations should be made explicit later.

### schtasks as the intended runtime surface
Microsoft’s `schtasks /create` documentation confirms scheduled execution is a first-class Windows path.

Why this matters here:
- It strengthens the conclusion that modal UI in the main runtime path is not a harmless cosmetic issue; it conflicts with the repo’s stated operating model.

## Recommended roadmap shape

### Now / highest leverage
1. Make scheduled runs headless by default.
2. Remove command-line secret exposure.
3. Strengthen prereq validation into operational-readiness validation.

### Next
4. Replace `Shell.Exec` with a safer runner and richer failure diagnostics.
5. Add deterministic Windows smoke coverage and CI entrypoints.

### After runtime reliability improves
6. Add `docs/status.md` and `docs/critical_todo.md` as durable evidence surfaces.
7. Define retention/recovery policy for logs, temp artifacts, and uploaded archives if the repo is moving toward broader reuse/sale.

## Assumptions

- This pass assumes the primary buyer/user story remains: a Windows user wants a low-touch daily backup flow driven by AutoHotkey + PowerShell + rclone.
- This pass assumes desktop notifications may still be useful for manual invocations, which is why the queue recommends **interactive opt-in**, not deletion of all user feedback.
- This pass assumes no hidden CI/test harness exists outside the commonly expected paths reviewed here.

## Unknowns / follow-up questions for future passes

- Is there already a Windows CI workflow under a nonstandard path or branch?
- Are there any real-world logs showing hangs or upload failures, or is the repo still mostly pre-release/manual?
- Is email notification expected to be optional forever, or should it eventually become provider-pluggable?
- Should archive verification (`zip.verify`) become the recommended default for release builds or remain opt-in for speed?

## Resulting prioritization change

The refreshed `docs/ai_todo.md` now prioritizes unattended reliability and runtime safety over generic CI/release-process work. That is the biggest correction from the previous backlog shape.
