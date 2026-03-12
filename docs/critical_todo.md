# Critical TODO

Last updated: 2026-03-12 (UTC)

This file lists only the current real blockers.

## Release blocker

- [ ] **Native Windows PASS evidence for the headless default gate**
  - Current state: `docs\headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
  - Why it blocks release confidence: GitHub Actions does not directly prove the no-dialog claim on a real Windows desktop, and the checked-in PASS artifact does not exist yet.
  - Required action: run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal, then rerun in `-Mode Pass -ObservedBy "YourName"` once the default path has been directly observed to stay headless. Include `-ScheduledTaskName "OneClickBackupDaily"` when scheduler proof is required.

## Review-surface blocker

- [ ] **Windows regression workflow still lacks durable artifacts**
  - Current state: `.github/workflows/windows-regression.yml` runs `scripts\Regression.ps1` but does not upload artifact bundles.
  - Why it blocks review quality: reviewers have a pass/fail run and console logs, but no stable downloadable evidence package to reference from docs or release notes.
  - Required action: make the workflow publish durable regression outputs/logs as artifacts and document the scope of what those artifacts prove.

## Not listed here on purpose

The stale smoke-command cleanup is still worthwhile, but it is **not** a blocker now that the canonical docs already default to the safe no-argument smoke path.
