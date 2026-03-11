# Deep Research — daily-ops-packager

Updated: 2026-03-11 16:19 UTC
Scope of this pass: local repo evidence only, docs-only maintenance pass, no source-code changes.

## Sources reviewed

### Local repo evidence
- `git status --short --branch`
- `README.md`
- `STATUS.md`
- `TODO_SHORT_TERM.md`
- `TODO_LONG_TERM.md`
- `USER_TODO.md`
- `docs/ai_todo.md` (pre-refresh)
- `docs/deep_research_auto.md` (pre-refresh)
- `docs/headless_default_release_gate.md`
- existence checks for `docs/status.md` and `docs/critical_todo.md`
- absence check for `.github/workflows/*`
- `src/OneClickBackup.ahk`
- `src/Lib/Shell.ahk`
- `src/Lib/Notify.ahk`
- `scripts/SendMail.ps1`
- `scripts/CheckPrereqs.ps1`
- `scripts/SmokeTest.ps1`
- `scripts/CheckHeadlessDefault.ps1`
- `scripts/VerifyNonInteractiveDefault.ps1`
- `scripts/CaptureHeadlessEvidence.ps1`
- `scripts/RunHeadlessEvidenceCapture.ps1`
- `scripts/AssertHeadlessReleaseGate.ps1`

## Current architecture snapshot

This repo is still a small Windows backup pipeline:

1. Validate config and runtime prerequisites.
2. Collect files modified today from `paths.watchDir`.
3. Copy matches into a temp workspace preserving relative paths.
4. Archive with 7-Zip.
5. Optionally verify the archive.
6. Upload with rclone.
7. Optionally send email.
8. Append summary CSV + logs.

That scope is still sane. The roadmap issue is not missing product breadth. It is that the repo still needs one trustworthy readiness contract, one canonical regression surface, and one final native-Windows proof pass for the headless-default claim.

## What changed since the previous research pass

### 1) The repo is clean in this maintenance pass
Evidence:
- `git status --short --branch` returned only `## master...origin/master`.

Consequence:
- The previous `docs/ai_todo.md` / `docs/deep_research_auto.md` statements about a dirty working tree are stale and should not drive prioritization.

### 2) `Shell.Exec(...)` is no longer the top blocker
Evidence:
- `src/Lib/Shell.ahk` now includes timeout handling.
- It records `durationMs`, `timeoutMs`, `timedOut`, and `pid` in the returned result.
- It captures stdout/stderr through temp files and reads them after the child exits.
- It kills the process tree on timeout.

Consequence:
- Runner hardening should be removed from the top queue for now.
- It may still deserve future scrutiny, but it is not the highest-impact remaining gap from current repo evidence.

### 3) SMTP secret handoff is also no longer a top-priority blocker
Evidence:
- `src/Lib/Notify.ahk` passes `-PasswordEnv`, not the password value itself.
- `scripts/SendMail.ps1` resolves the secret from the named environment variable inside PowerShell.

Consequence:
- The previous `P0` around argv secret exposure is stale in the current repo state.
- This should stay out of the active top queue unless the implementation is reverted.

## Highest-impact findings from current repo evidence

### 1) Readiness validation still drifts between PowerShell and AHK
Evidence:
- `ValidatePrereqs(...)` in `src/OneClickBackup.ahk` checks `watchDir`, `patterns.extensions`, `tmpDir`, `outDir`, `zip.exe`, `zip.passwordEnv`, `zip.archiveName`, `rclone.exe`, `rclone.remote`, and email settings/env vars when enabled.
- `scripts/CheckPrereqs.ps1` checks only config existence, `7z.exe`, `rclone.exe`, `zip.passwordEnv`, and `email.passwordEnv` when email is enabled.
- `scripts/SmokeTest.ps1` depends on `scripts/CheckPrereqs.ps1`, so the documented PowerShell happy path inherits the shallower contract.

Implication:
- A user can still get a green prereq result and then fail immediately at runtime.

Roadmap consequence:
- This should be the first executable queue item.
- The fix should include shared fixture configs so the same pass/fail cases are tested through both entrypoints.

### 2) There are no fixture configs for deterministic pass/fail validation
Evidence:
- `config/` contains `app.ini` and `app.sample.ini`, but no `config/fixtures/*` files.

Implication:
- There is no stable way to prove that prereq/readiness behavior stays aligned across future refactors.

Roadmap consequence:
- Fixture configs should ship with the readiness-validation work, not as an afterthought.

### 3) Regression coverage exists, but there is still no canonical regression command
Evidence:
- `scripts/CheckHeadlessDefault.ps1` exists.
- `scripts/SmokeTest.ps1` exists.
- `.github/workflows` is absent.
- `scripts/Regression.ps1` does not exist.

Implication:
- The repo has useful pieces, but no single command that says “this repo still basically works.”

Roadmap consequence:
- Add a canonical local regression entrypoint.
- CI is optional, but the local command should exist either way.

### 4) Headless static validation is duplicated and mildly confusing
Evidence:
- `scripts/CheckHeadlessDefault.ps1` is referenced by README, user docs, and the evidence-capture flow.
- `scripts/VerifyNonInteractiveDefault.ps1` is not referenced anywhere outside planning docs.
- `CheckHeadlessDefault.ps1` is the more comprehensive guard.

Implication:
- Keeping both scripts without a clear owner invites drift and weakens trust in static validation.

Roadmap consequence:
- Collapse onto one canonical static guard.
- Either delete `VerifyNonInteractiveDefault.ps1` or make it a trivial wrapper.

### 5) The headless-default release gate is still open, but it is now mainly an evidence problem
Evidence:
- `docs/headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
- `scripts/CaptureHeadlessEvidence.ps1`, `scripts/RunHeadlessEvidenceCapture.ps1`, and `scripts/AssertHeadlessReleaseGate.ps1` now provide a coherent capture/assert flow.
- The current OpenClaw/WSL session still cannot complete the native Windows execution needed for final proof.

Implication:
- The headless-default claim is close, but not closed.
- The remaining work is operational evidence, not large code churn.

Roadmap consequence:
- Keep this item in the top tier, but below the unblocked repo work.

### 6) Release-state docs are still fragmented and partially stale
Evidence:
- `docs/status.md` is missing.
- `docs/critical_todo.md` is missing.
- Root `STATUS.md` still leads with installer packaging.

Implication:
- Humans or agents reading only the obvious status file can still be pointed at the wrong next step.

Roadmap consequence:
- Canonicalize release-state docs after the runtime blocker stack is sorted.

## Recommended roadmap order

### Now / highest leverage
1. Unify readiness validation across `CheckPrereqs.ps1` and `ValidatePrereqs(...)`.
2. Add fixture configs for deterministic pass/fail validation.
3. Add `scripts/Regression.ps1` as the canonical local regression entrypoint.
4. Collapse duplicate headless static guards onto one canonical script.
5. Close the headless-default release gate with native Windows evidence.
6. Add `docs/status.md` and `docs/critical_todo.md`, then reconcile root `STATUS.md`.

### Explicitly demoted from the top queue
- `Shell.Exec(...)` hardening: current repo evidence shows timeout + capture support already exists.
- SMTP argv-secret removal: current repo evidence shows env-name handoff is already implemented.
- Installer packaging: still valid later, but should remain downstream of runtime confidence.

## Assumptions

- The current checked-in source accurately reflects intended behavior.
- The main distribution target is still a Windows user running AutoHotkey + PowerShell + rclone locally or via Task Scheduler.
- The headless-default release claim should not be treated as closed until native Windows evidence is committed.
- This maintenance pass is docs-only, so missing docs are recorded as roadmap gaps rather than created here.

## Unknowns for a future pass

- Should the shared readiness contract live in PowerShell, AHK, or a shared declarative fixture/spec layer?
- Is Windows CI actually wanted here, or is a canonical local regression command sufficient?
- Should `VerifyNonInteractiveDefault.ps1` be deleted outright or kept as a thin compatibility shim?
- Are there any real-world failure logs yet for archive, upload, or email paths that should influence regression coverage?

## Resulting prioritization change

This refresh changes the queue materially:

1. **Removed** the stale `Shell.Exec` blocker from the top queue.
2. **Removed** the stale SMTP argv-secret blocker from the top queue.
3. **Promoted** readiness-validation unification to the first executable item.
4. **Promoted** fixture-backed regression work because the repo still lacks one canonical confidence command.
5. **Kept** the native-Windows evidence task in the top tier, but below unblocked repo work.
6. **Kept** docs canonicalization as cleanup after the runtime blocker stack, not as a substitute for it.