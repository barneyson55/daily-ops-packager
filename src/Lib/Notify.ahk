class Notify {
  static Send(emailCfg, subject, body) {
    if (!emailCfg.enabled)
      return

    if (emailCfg.passwordEnv = "")
      throw Error("email.passwordEnv is empty")

    scriptPath := DirGetParent(A_ScriptDir) "\\scripts\\SendMail.ps1"
    cmd := "powershell -NoProfile -ExecutionPolicy Bypass -File " . Shell.Quote(scriptPath)
    cmd .= " -SmtpHost " . Shell.Quote(emailCfg.smtpHost)
    cmd .= " -SmtpPort " . emailCfg.smtpPort
    cmd .= " -UseSsl " . emailCfg.useSsl
    cmd .= " -From " . Shell.Quote(emailCfg.from)
    cmd .= " -To " . Shell.Quote(emailCfg.to)
    cmd .= " -User " . Shell.Quote(emailCfg.user)
    cmd .= " -PasswordEnv " . Shell.Quote(emailCfg.passwordEnv)
    cmd .= " -Subject " . Shell.Quote(subject)
    cmd .= " -Body " . Shell.Quote(body)

    Logger.Info("Sending email: " cmd)

    result := Shell.Exec(cmd, "", true)
    if (result.stdout != "")
      Logger.Info("SendMail stdout: " Trim(result.stdout))
    if (result.stderr != "")
      Logger.Warn("SendMail stderr: " Trim(result.stderr))

    Logger.Info("SendMail exit code: " result.exitCode " durationMs=" result.durationMs " timedOut=" result.timedOut)

    if (result.timedOut)
      throw Error("SendMail.ps1 timed out after " result.durationMs " ms")
    if (result.exitCode != 0)
      throw Error("SendMail.ps1 failed with exit code " result.exitCode)
  }
}
