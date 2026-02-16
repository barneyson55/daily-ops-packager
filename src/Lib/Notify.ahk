class Notify {
  static Send(emailCfg, subject, body) {
    if (!emailCfg.enabled)
      return

    pass := EnvGet(emailCfg.passwordEnv)
    if (pass = "")
      throw Error("Missing SMTP password env: " emailCfg.passwordEnv)

    scriptPath := DirGetParent(A_ScriptDir) "\\scripts\\SendMail.ps1"
    cmd := "powershell -NoProfile -ExecutionPolicy Bypass -File " . Shell.Quote(scriptPath)
    cmd .= " -SmtpHost " . Shell.Quote(emailCfg.smtpHost)
    cmd .= " -SmtpPort " . emailCfg.smtpPort
    cmd .= " -UseSsl " . emailCfg.useSsl
    cmd .= " -From " . Shell.Quote(emailCfg.from)
    cmd .= " -To " . Shell.Quote(emailCfg.to)
    cmd .= " -User " . Shell.Quote(emailCfg.user)
    cmd .= " -Password " . Shell.Quote(pass)
    cmd .= " -Subject " . Shell.Quote(subject)
    cmd .= " -Body " . Shell.Quote(body)

    logCmd := StrReplace(cmd, Shell.Quote(pass), """***""")
    Logger.Info("Sending email: " logCmd)

    result := Shell.Exec(cmd, "", true)
    if (result.stdout != "")
      Logger.Info("SendMail stdout: " Trim(result.stdout))
    if (result.stderr != "")
      Logger.Warn("SendMail stderr: " Trim(result.stderr))

    if (result.exitCode != 0)
      throw Error("SendMail.ps1 failed with exit code " result.exitCode)
  }
}
