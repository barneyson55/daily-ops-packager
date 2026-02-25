# Troubleshooting

## rclone remote not found
- Ensure `rclone config` has a remote matching `rclone.remote` in the INI.
- Run `rclone listremotes` to verify.

## 7-Zip path invalid
- Confirm `zip.exe` points to a real `7z.exe` path.
- Test with `"C:\\Program Files\\7-Zip\\7z.exe" -h`.

## Missing environment variables
- Set `DAILY_ZIP_PASS` (and `DAILY_SMTP_PASS` if email is enabled).
- Verify with `setx DAILY_ZIP_PASS "yourPassword"` or PowerShell `Get-ChildItem Env:DAILY_ZIP_PASS`.

## SMTP auth failures
- Check `email.user` and `email.passwordEnv`.
- Confirm SMTP host/port/SSL requirements with your provider.

## No files matched
- Ensure the files were modified today (local time).
- Confirm `patterns.extensions` matches the files you expect.

## ASPM TODO file path mismatch
- Current canonical user backlog file is repository-root `USER_TODO.md` (uppercase), not `docs/user_todo.md`.
- If automation reports `docs/user_todo.md` missing, treat it as "no docs user_todo" and continue from `docs/ai_todo.md`.
- Optional normalization: add a small pointer file at `docs/user_todo.md` that references `../USER_TODO.md`.
