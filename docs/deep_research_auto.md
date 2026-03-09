# Deep Research — daily-ops-packager

Updated: 2026-03-09 17:49 UTC
Scope of this pass: local evidence first, minimal external validation second. No code changes in this maintenance pass.

Maintenance note (17:49 UTC): `docs/ai_todo.md` was refreshed again after reviewing the current repo status/planning surfaces, not just the implementation docs. The biggest correction in this pass is that the repo should now be treated as a **runtime-hardening release candidate**, not as an installer-packaging project.

## Sources reviewed

### Local repo evidence
- `README.md`
- `STATUS.md`
- `TODO_SHORT_TERM.md`
- `TODO_LONG_TERM.md`
- `USER_TODO.md`
- `docs/ARCHITECTURE.md`
- `docs/CONFIG.md`
- `docs/TROUBLESHOOTING.md`
- `docs/headless_default_release_gate.md`
- `docs/deep_research_auto.md` (previous pass)
- `docs/ai_todo.md` (pre-refresh queue)
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
- `scripts/SendMail.ps1`
- `scripts/SmokeTest.ps1`
- `scripts/CaptureHeadlessEvidence.ps1`
- absence checks for `docs/status.md`, `docs/critical_todo.md`, and `.github/workflows/*`

### Minimal external validation
- rclone official docs: `https://rclone.org/commands/rclone_copy/`
  - reconfirmed that `rclone copy` is additive and does **not** delete destination files
- Microsoft docs: `https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create`
  - reconfirmed that Task Scheduler / `schtasks` is a first-class scheduled-execution surface for this Windows workflow

## Architecture snapshot

This repo is still a focused single-user Windows automation pipeline:

1. load INI config
2. validate tool paths + secrets
3. collect files modified today
4. copy to temp workspace preserving relative paths
5. archive with 7-Zip
6. optionally verify archive
7. upload with rclone
8. optionally send email
9. append summary CSV + write logs

That narrow scope is fine. The real work now is not adding breadth; it is closing the gap between the repo's stated unattended usage model and its release proof / runtime safety.

## What the repo already does well

- Clear pipeline boundaries in source and docs.
- Strong baseline principle: source files are never mutated.
- Failure artifacts are intentionally kept for inspection.
- Secrets are not stored in config files.
- Summary CSV gives a compact operational ledger.
- Setup guidance for first-time Windows users is already extensive.
- The headless-default evidence capture path is materially better than before: runtime context, smoke output, summary tail, log tail, and optional scheduler proof can now be captured into one durable markdown artifact.

## Highest-impact findings from repo evidence

### 1) Headless-by-default is now mostly an evidence problem, not an implementation problem

Evidence:
- `README.md` and `USER_TODO.md` now clearly document headless default behavior.
- `src/OneClickBackup.ahk` only calls `MsgBox` through `MaybeShowDialog(...)`, and that helper only shows dialogs when `--interactive` is enabled.
- `scripts/CheckHeadlessDefault.ps1` and `scripts/CaptureHeadlessEvidence.ps1` exist specifically to guard and capture that claim.
- `docs/headless_default_release_gate.md` is still `PENDING_REAL_RUN` because this WSL/OpenClaw session cannot launch native Windows binaries.

Implication:
- The remaining blocker is release proof on real Windows, not feature invention.

Roadmap consequence:
- Keep the headless release gate at the top until a native Windows run closes it with durable evidence.

### 2) Secret posture is good at the config layer but still weak at the process-boundary layer

Evidence:
- Docs correctly say secrets belong in environment variables.
- `src/Lib/Notify.ahk` still builds a PowerShell command line containing the SMTP password.
- `scripts/SendMail.ps1` still accepts the password as a plain string parameter and only converts it to `SecureString` after it is already on argv.

Implication:
- The repo avoids committing secrets, but still risks exposing them at runtime through process arguments, support captures, or local inspection tools.

Roadmap consequence:
- Secret-boundary hardening stays P0 and should not slip behind packaging or docs polish.

### 3) The current process runner is still the most likely unattended reliability bottleneck

Evidence:
- `src/Lib/Shell.ahk` waits for process completion before draining stdout/stderr.
- `ZipPack`, `RcloneUpload`, and `Notify` all depend on this runner.

Implication:
- Verbose or stuck child processes can become harder to diagnose and may be brittle in unattended operation.

Roadmap consequence:
- Improve the runner before treating the repo as release-stable.

### 4) Readiness checks are still too shallow for first-run success

Evidence:
- `scripts/CheckPrereqs.ps1` validates binary presence and required env vars.
- It still does not validate watch-dir existence, temp/output writability, archive-name sanity, or remote reachability.

Implication:
- A user can pass prereqs and still fail immediately on first real run.

Roadmap consequence:
- Promote prereq validation into an actual readiness gate before broader distribution.

### 5) Regression confidence is still too manual for a repo that wants unattended scheduling

Evidence:
- `scripts/SmokeTest.ps1` exists and is useful.
- `.github/workflows` is absent.
- There is still no durable documented failure-path regression surface for upload/mail/zip paths.

Implication:
- The happy path has guidance, but refactor safety is still weak.

Roadmap consequence:
- Add deterministic Windows regression coverage before installer packaging or broader productization work.

### 6) Planning surfaces are fragmented and already drifting away from the real release gates

Evidence:
- Root `STATUS.md` still says the first top-level task is installer packaging + prerequisite checks.
- `TODO_SHORT_TERM.md` is fully historical/checked-off.
- `TODO_LONG_TERM.md` still lists packaging, licensing, retention, dashboarding, and telemetry themes.
- `docs/status.md` and `docs/critical_todo.md` do not exist yet.
- The most truthful live blocker surface is currently `docs/ai_todo.md` + `docs/headless_default_release_gate.md`.

Implication:
- A human or agent reading only `STATUS.md` can be nudged toward the wrong next step.

Roadmap consequence:
- Once the runtime blockers are narrowed, create canonical docs status surfaces and explicitly demote installer packaging until the release-hardening gates are closed.

## External validation and why it matters

### rclone copy semantics
Official `rclone copy` docs state that copy does **not** delete files from the destination.

Why this matters here:
- The current product behavior is additive backup, not source/destination mirroring.
- That matches the repo's safety posture.
- It also means retention/cleanup remains a later product decision, not a current P0 blocker.

### schtasks as the intended runtime surface
Microsoft's `schtasks /create` documentation confirms scheduled execution is a first-class Windows path.

Why this matters here:
- It strengthens the conclusion that headless-default proof is not cosmetic.
- If the product is positioned for Task Scheduler use, unattended behavior needs release-grade evidence.

## Recommended roadmap shape

### Now / highest leverage
1. Close the headless-default release gate with real Windows smoke evidence.
2. Remove command-line secret exposure.
3. Replace `Shell.Exec` with a safer runner and richer failure diagnostics.
4. Expand prereq validation into operational-readiness validation.
5. Add deterministic Windows regression coverage.

### Next
6. Add `docs/status.md` and `docs/critical_todo.md`, and reconcile stale root planning surfaces so they reflect the real blocker stack.

### Later
7. Revisit installer packaging only after unattended runtime proof, secret handling, runner safety, prereq coverage, and regression confidence are in place.
8. Define retention/recovery policy for logs, temp artifacts, and uploaded archives if the repo moves toward broader reuse or sale.

## Assumptions

- The primary buyer/user story is still: a Windows user wants a low-touch daily backup flow driven by AutoHotkey + PowerShell + rclone.
- Desktop dialogs are still useful for manual invocations, which is why the repo should preserve **interactive opt-in** instead of deleting all user feedback.
- No hidden CI/test harness exists outside the common paths reviewed here.
- The current maintenance pass is docs-only, so stale root planning files are treated as evidence and reprioritization inputs, not directly edited targets.

## Unknowns / follow-up questions for future passes

- Is there already a Windows CI workflow under a nonstandard path or branch?
- Are there any real-world logs showing hangs or upload failures, or is the repo still mostly pre-release/manual?
- Should `SendMail.ps1` read credentials directly from environment at execution time, or should the mail path move away from child-process secret handoff entirely?
- Should archive verification (`zip.verify`) become the recommended default for release builds or remain opt-in for speed?
- After the release-hardening gates close, is installer packaging still the right next commercial step, or is a portable/internal distribution tier enough first?

## Resulting prioritization change

The refreshed `docs/ai_todo.md` keeps the same core top three themes as the earlier pass — headless proof, secret handling, runner reliability — but tightens the queue in two ways:

1. It explicitly reframes the repo as a **release-hardening** effort rather than an installer-packaging effort.
2. It broadens the final docs item from “add missing status docs” into “canonicalize release-state docs and retire stale planning drift,” because root `STATUS.md` is now materially misaligned with the repo's actual blocker stack.
