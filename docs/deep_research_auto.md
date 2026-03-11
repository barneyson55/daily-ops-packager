# Deep Research — daily-ops-packager

Updated: 2026-03-11 15:13 UTC
Scope of this pass: local repo evidence first, minimal external validation second. No source-code changes in this maintenance pass.

Maintenance note (2026-03-11): the biggest roadmap correction is now twofold: (1) the previous `docs/ai_todo.md` had gone stale on SMTP secret handoff because the current working tree no longer passes the password on argv, and (2) the first unchecked item must stay executable by autopilot, so the blocked native-Windows evidence task should not sit above unblocked repo work.

## Sources reviewed

### Local repo evidence
- `git status --short --branch`
- `git diff --name-only`
- `README.md`
- `STATUS.md`
- `TODO_SHORT_TERM.md`
- `TODO_LONG_TERM.md`
- `USER_TODO.md`
- `docs/ARCHITECTURE.md`
- `docs/CONFIG.md`
- `docs/TROUBLESHOOTING.md`
- `docs/ai_todo.md` (pre-refresh)
- `docs/deep_research_auto.md` (pre-refresh)
- `docs/headless_default_release_gate.md`
- existence checks for `docs/status.md` and `docs/critical_todo.md`
- absence check for `.github/workflows/*`
- `config/app.sample.ini`
- `src/OneClickBackup.ahk`
- `src/Lib/Notify.ahk`
- `src/Lib/Shell.ahk`
- `scripts/CheckHeadlessDefault.ps1`
- `scripts/VerifyNonInteractiveDefault.ps1`
- `scripts/CheckPrereqs.ps1`
- `scripts/SmokeTest.ps1`
- `scripts/CaptureHeadlessEvidence.ps1`
- `scripts/RunHeadlessEvidenceCapture.ps1`
- `scripts/SendMail.ps1`

### Minimal external validation
- rclone official docs: `https://rclone.org/commands/rclone_copy/`
  - reconfirmed that `rclone copy` is additive and **does not delete destination files**
- Microsoft docs: `https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create`
  - reconfirmed that `schtasks` / Task Scheduler is a first-class Windows scheduling surface for this workflow
- Microsoft .NET docs / official snippet via search results: `https://learn.microsoft.com/en-us/dotnet/api/system.net.mail.smtpclient?view=net-10.0`
  - Microsoft does **not recommend `SmtpClient` for new development** because it lacks support for many modern protocols; that is a compatibility watch-item, not the current top blocker

## Current architecture snapshot

This repo is still a narrow Windows automation pipeline with two validation layers:

1. PowerShell preflight (`scripts/CheckPrereqs.ps1`)
2. AHK runtime validation (`ValidatePrereqs(...)` in `src/OneClickBackup.ahk`)
3. collect files modified today
4. copy to temp workspace preserving relative paths
5. archive with 7-Zip
6. optionally verify archive
7. upload with rclone
8. optionally send email via PowerShell SMTP helper
9. append summary CSV + write logs

That scope is still fine. The problem is no longer missing product breadth. The problem is that release confidence still depends on runtime proof, runner safety, and validation consistency.

## What the repo already does well

- Clear single-purpose pipeline and docs.
- Good default safety posture: copy-then-archive, no source mutation.
- Failure artifacts are preserved for inspection.
- Headless default is explicit in docs and enforced in source structure.
- A durable Windows evidence capture flow now exists for the headless-default claim.
- Secrets are documented as environment-sourced rather than committed config values.
- Summary CSV gives a compact operational ledger.

## Highest-impact findings from repo evidence

### 1) The headless-default blocker is still real, but it is now almost entirely an evidence problem

Evidence:
- `README.md`, `USER_TODO.md`, and `docs/headless_default_release_gate.md` all describe scheduled/CLI runs as headless by default.
- `src/OneClickBackup.ahk` routes user-facing dialogs through `MaybeShowDialog(...)`, and that helper calls `MsgBox` only when `--interactive` is enabled.
- `scripts/CheckHeadlessDefault.ps1`, `scripts/CaptureHeadlessEvidence.ps1`, and `scripts/RunHeadlessEvidenceCapture.ps1` now form a coherent proof path.
- This OpenClaw/WSL session still cannot launch native Windows binaries, so the gate remains `PENDING_REAL_RUN`.

Implication:
- The highest-leverage next step is still a real Windows run that turns the release-gate doc to `PASS`.

Roadmap consequence:
- Keep the headless-default gate in the top tier, but not as the first executable queue item while this session still cannot cross the Windows boundary.

### 2) The previous SMTP argv-secret blocker is stale in the current working tree

Evidence:
- `src/Lib/Notify.ahk` now passes `-PasswordEnv`, not the actual secret value.
- `scripts/SendMail.ps1` now resolves the SMTP password from the named environment variable inside PowerShell.
- The logging line now exposes the environment-variable name, not the password itself.
- `git status` / `git diff --name-only` show that `src/Lib/Notify.ahk` and `scripts/SendMail.ps1` are modified in the current working tree.

Implication:
- Re-spending top-of-queue effort on argv-secret removal would be wasteful if these changes are intended and preserved.
- However, because the repo is dirty, the fix is not yet something docs should treat as irrevocably landed.

Roadmap consequence:
- Remove SMTP argv exposure from the active top priorities.
- Add a note/risk that if the local mail changes are dropped, the issue becomes P0 again.

### 3) Validation drift is now a bigger correctness problem than SMTP secret handoff

Evidence:
- `ValidatePrereqs(...)` in `src/OneClickBackup.ahk` checks `watchDir`, `tmpDir`, `outDir`, archive-name presence, `rclone.remote`, and env-var presence.
- `scripts/CheckPrereqs.ps1` checks only config existence, `7z.exe`, `rclone.exe`, and required env vars.
- `scripts/SmokeTest.ps1` depends on `CheckPrereqs.ps1`, so the documented smoke path inherits the shallower PowerShell contract.

Implication:
- A user can get a green prereq check and still fail immediately at runtime.
- That makes first-run guidance look more complete than it really is.

Roadmap consequence:
- Promote unified readiness validation into the top tier.
- Prefer one shared readiness contract rather than separate PowerShell-vs-AHK rules that drift.

### 4) `Shell.Exec(...)` is still the main unattended-runtime risk surface

Evidence:
- `src/Lib/Shell.ahk` waits for process completion before draining `StdOut` and `StdErr`.
- There is no timeout handling.
- `7z`, `rclone`, and PowerShell mail all depend on this runner.

Implication:
- Long or noisy subprocesses remain a plausible source of hangs, partial diagnostics, or support pain.

Roadmap consequence:
- Runner hardening should become the first executable queue item until native Windows proof can be gathered.

### 5) Regression coverage is still partial and slightly fragmented

Evidence:
- `scripts/SmokeTest.ps1` exists.
- `scripts/CheckHeadlessDefault.ps1` exists and is referenced by docs/capture flow.
- `.github/workflows` is absent.
- `scripts/VerifyNonInteractiveDefault.ps1` exists but is not referenced by README, user docs, or capture scripts.

Implication:
- The repo has useful manual checks, but not one canonical regression surface.
- There is also a small static-check duplication risk around the two headless-verification scripts.

Roadmap consequence:
- Add a canonical Windows regression entrypoint and either remove or wire in the duplicate static guard.

### 6) Planning surfaces are still fragmented, and root status is materially stale

Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still leads with installer packaging as the first top-level task.
- The most accurate roadmap surface is now `docs/ai_todo.md` + `docs/deep_research_auto.md`, not the official-looking root status file.

Implication:
- Humans and agents can be steered toward the wrong next step if they read only root status.

Roadmap consequence:
- Canonicalize release-state docs after the top runtime blockers are made explicit.

### 7) Email transport is not the top blocker anymore, but it is still a medium-term compatibility watch-item

Evidence:
- `scripts/SendMail.ps1` uses `System.Net.Mail.SmtpClient`.
- Microsoft does not recommend `SmtpClient` for new development because it lacks support for many modern protocols.

Implication:
- For a simple SMTP relay/user-password workflow, the current implementation may be acceptable.
- If the repo later targets providers that require OAuth or more modern auth flows, this path may become a real product constraint.

Roadmap consequence:
- Do not elevate this above headless proof, runner safety, readiness validation, or regression coverage right now.
- Keep it in the "later / compatibility" bucket unless real provider failures appear.

## External validation and why it matters

### rclone copy semantics
Official docs say `rclone copy` does **not** delete files from the destination.

Why it matters here:
- Confirms the product's current upload behavior is additive backup, not mirroring.
- Supports keeping retention/cleanup as a later product decision, not a current release blocker.

### schtasks as the intended runtime surface
Microsoft docs confirm `schtasks` is a standard Windows scheduling surface.

Why it matters here:
- Reinforces that headless-default proof is not cosmetic.
- If Task Scheduler is the intended operational mode, unattended behavior needs release-grade evidence.

### SmtpClient guidance
Microsoft docs/search snippets explicitly say `SmtpClient` is not recommended for new development.

Why it matters here:
- Useful for roadmap hygiene: the mail path is now safer on secret handoff, but still not future-proof for every SMTP provider.
- This is a compatibility/design concern, not the immediate blocker stack.

## Recommended roadmap shape

### Now / highest leverage
1. Replace `Shell.Exec(...)` with a safer unattended runner.
2. Unify prereq/readiness validation across PowerShell and AHK runtime.
3. Add a deterministic Windows regression entrypoint covering headless + smoke + failure paths.
4. Close the headless-default release gate with native Windows evidence once a real Windows terminal is available.
5. Canonicalize release-state docs so `STATUS.md` stops pointing at installer packaging first.

### Watch closely
6. Ensure the current `Notify.ahk` / `SendMail.ps1` env-based secret-handoff changes are actually kept; if reverted, argv secret exposure becomes urgent again.

### Later
7. Revisit installer packaging only after runtime proof and validation hardening are closed.
8. Revisit SMTP transport/library choice if target providers or auth requirements outgrow `SmtpClient`.
9. Define retention/recovery policy once the unattended runtime path is considered stable.

## Assumptions

- The current dirty working tree reflects intended direction, not accidental local edits.
- The primary user story is still a Windows user running scheduled backups via AutoHotkey + PowerShell + rclone.
- Email notifications are still aimed at basic SMTP username/password relays, not OAuth-first providers.
- No hidden CI/test harness exists outside the standard locations reviewed here.
- This maintenance pass is docs-only, so stale root planning files are treated as evidence inputs rather than directly edited targets.

## Unknowns / follow-up questions for future passes

- Will the current `Notify.ahk` / `SendMail.ps1` changes be committed, or are they still experimental?
- Should readiness validation live primarily in PowerShell, in AHK, or in a shared declarative contract?
- Is `scripts/VerifyNonInteractiveDefault.ps1` dead code, or was it intended to replace `CheckHeadlessDefault.ps1`?
- Are there any real-world Windows logs showing hangs, upload failures, or mail failures yet?
- Which SMTP providers are expected in practice, and do any already require OAuth or newer auth flows?
- Is a documented local regression script enough, or does this repo actually need Windows CI before broader distribution?

## Resulting prioritization change

This refresh changes the queue more materially than the previous pass:

1. **Removed** the stale `P0 — Remove command-line SMTP secret exposure` item from the active top priorities because the current working tree already routes mail secrets by env-var name.
2. **Moved down** the native-Windows headless evidence task from the first executable slot because it is still blocked by the current WSL/OpenClaw boundary.
3. **Promoted** runner hardening, readiness-validation unification, and the canonical regression entrypoint into the top executable tier because they are the highest-impact repo tasks that can actually be worked now.
4. **Kept** docs canonicalization, but explicitly framed it as cleanup after the runtime blocker stack rather than a substitute for it.
