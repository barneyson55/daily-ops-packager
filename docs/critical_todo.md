# Critical TODO

Last updated: 2026-03-12 08:29 UTC

This file lists only the current real blockers.

## Release blocker

- [ ] **Native Windows PASS evidence for the headless default gate**
  - Current state: `docs\headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
  - Why it blocks release confidence: GitHub Actions does not directly prove the no-dialog claim on a real Windows desktop, and the checked-in PASS artifact does not exist yet.
  - Required action: run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal, then rerun in `-Mode Pass -ObservedBy "YourName"` once the default path has been directly observed to stay headless. Include `-ScheduledTaskName "OneClickBackupDaily"` when scheduler proof is required.

## Not listed here on purpose

- Workflow artifact publishing is **not** the main release blocker, but a fresh live re-check at `2026-03-12 08:29 UTC` still found only workflow-file failures for `windows-regression.yml` and `0` stored Actions artifacts, so artifact-download verification remains an active follow-up rather than a closed proof point.
- The stale smoke-command cleanup is still worthwhile, but it is **not** a blocker now that the canonical docs already default to the safe no-argument smoke path.
