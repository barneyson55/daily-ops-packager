# ASPM Sellable Delivery Scope — 2026-02-16 (wave2)

Repository: `daily-ops-packager`

This wave adds a **client-ready delivery scope card** so this project can be sold as a scoped implementation package immediately.

## Docs/TODOs inspected
- `README.md`
- `STATUS.md`
- `docs/ai_todo.md`
- `TODO_LONG_TERM.md`
- `TODO_SHORT_TERM.md`
- `USER_TODO.md`
- `docs/aspm_ai_todo_2026-02-16.md`

## Concrete improvement delivered in this commit
A productized **Delivery Scope Card** with:
1. Offer framing (what is sold in a fixed scope)
2. Acceptance checklist (definition of done)
3. Demo + handoff flow for buyer confidence
4. Backlog anchors tied to currently visible TODO/STATUS items

### Offer framing
Package the automation workflow as a scoped deliverable with preflight checks and clear handoff steps.

### Acceptance checklist
- [ ] Automation entrypoint and dependencies are documented.
- [ ] At least one deterministic local smoke command is specified.
- [ ] Outstanding TODOs are translated into sellable milestones.

### Demo & handoff flow
- Run deterministic local preflight/smoke command
- Show success criteria and rollback notes
- Review milestone plan for client delivery

### Backlog anchors from inspected docs
- config\app.sample.ini -> config\app.ini
- DAILY_ZIP_PASS
- DAILY_SMTP_PASS (only if email is enabled)
- src\OneClickBackup.ahk --config config\app.ini --dry-run
- or use the safe default smoke test script: powershell -NoProfile -ExecutionPolicy Bypass -File scripts\SmokeTest.ps1
- src\OneClickBackup.ahk --config config\app.ini
