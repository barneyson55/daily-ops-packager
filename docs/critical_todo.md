# Critical TODO

Last updated: 2026-03-13 08:26 UTC

This file lists only the current real blockers.

## Release blocker

- [ ] **Native Windows PASS evidence for the headless default gate**
  - Current state: `docs\headless_default_release_gate.md` is still `Status: **PENDING_REAL_RUN**`.
  - Why it blocks release confidence: GitHub Actions now gives freshly rechecked regression evidence via successful run `23039582037` and its retained artifact bundle, but that still does not directly prove the no-dialog claim on a real Windows desktop.
  - Required action: run `scripts\RunHeadlessEvidenceCapture.ps1` from a native Windows terminal, then rerun in `-Mode Pass -ObservedBy "YourName"` once the default path has been directly observed to stay headless. Include `-ScheduledTaskName "OneClickBackupDaily"` when scheduler proof is required.

## Not listed here on purpose

- Workflow artifact publishing is **not** the main release blocker, and a fresh recheck at `2026-03-13 08:26 UTC` confirmed successful run `23039582037`, a retained artifact bundle, and the expected `regression.log` / `regression-summary.md` / `workflow-context.txt` contents.
- The stale smoke-command cleanup is still worthwhile, but it is **not** a blocker now that the canonical docs already default to the safe no-argument smoke path.
