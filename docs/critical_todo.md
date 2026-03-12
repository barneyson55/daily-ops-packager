# Critical TODO

Last updated: 2026-03-12 (UTC)

This file lists only the current real blockers.

## Release blocker

- [ ] **Native Windows PASS evidence for the headless default gate**
  - Current state: `docs\headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
  - Why it blocks release confidence: GitHub Actions does not directly prove the no-dialog claim on a real Windows desktop, and the checked-in PASS artifact does not exist yet.
  - Required action: run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal, then rerun in `-Mode Pass -ObservedBy "YourName"` once the default path has been directly observed to stay headless. Include `-ScheduledTaskName "OneClickBackupDaily"` when scheduler proof is required.

## Not listed here on purpose

- The Windows regression workflow now publishes downloadable artifact bundles, so workflow artifacting is no longer a blocker.
- The stale smoke-command cleanup is still worthwhile, but it is **not** a blocker now that the canonical docs already default to the safe no-argument smoke path.
