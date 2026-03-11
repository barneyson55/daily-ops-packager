class Shell {
  static defaultTimeoutMs := 1800000
  static pollIntervalMs := 100

  static Quote(arg) {
    if (arg = "")
      return '""'
    return '"' StrReplace(arg, '"', '""') '"'
  }

  static Exec(command, workDir := "", logOutput := false, timeoutMs := "") {
    if (timeoutMs = "")
      timeoutMs := this.defaultTimeoutMs

    tempDir := A_Temp "\\oneclick_backup_shell"
    DirCreate(tempDir)

    token := A_NowUTC "_" A_TickCount "_" Random(1000, 9999)
    runnerPath := tempDir "\\runner_" token ".cmd"
    stdoutPath := tempDir "\\stdout_" token ".log"
    stderrPath := tempDir "\\stderr_" token ".log"

    durationMs := 0
    result := ""
    stdout := ""
    stderr := ""

    try {
      this._WriteRunner(runnerPath, command, stdoutPath, stderrPath)
      startedAt := A_TickCount
      pid := this._RunDetached(runnerPath, workDir)
      result := this._WaitForExit(pid, timeoutMs)
      durationMs := A_TickCount - startedAt

      if (logOutput) {
        stdout := this._ReadText(stdoutPath)
        stderr := this._ReadText(stderrPath)
        if (result.timedOut) {
          timeoutMsg := "Command timed out after " durationMs " ms"
          stderr := stderr = "" ? timeoutMsg : RTrim(stderr, "`r`n") "`r`n" timeoutMsg
        }
      }

      return {
        exitCode: result.exitCode,
        stdout: stdout,
        stderr: stderr,
        timedOut: result.timedOut,
        durationMs: durationMs,
        timeoutMs: timeoutMs,
        pid: pid
      }
    } finally {
      this._DeleteIfExists(runnerPath)
      this._DeleteIfExists(stdoutPath)
      this._DeleteIfExists(stderrPath)
    }
  }

  static _RunDetached(runnerPath, workDir) {
    comSpec := EnvGet("ComSpec")
    if (comSpec = "")
      throw Error("ComSpec is not set")

    pid := 0
    Run(this.Quote(comSpec) " /d /c " this.Quote(runnerPath), workDir, "Hide", &pid)
    return pid
  }

  static _WaitForExit(pid, timeoutMs) {
    access := 0x00100000 | 0x1000
    handle := DllCall("OpenProcess", "UInt", access, "Int", false, "UInt", pid, "Ptr")
    if (!handle)
      throw OSError()

    timedOut := false
    exitCode := -1
    startedAt := A_TickCount

    try {
      loop {
        waitMs := this.pollIntervalMs
        if (timeoutMs > 0) {
          remaining := timeoutMs - (A_TickCount - startedAt)
          if (remaining <= 0) {
            timedOut := true
            break
          }
          if (remaining < waitMs)
            waitMs := remaining
        }

        waitResult := DllCall("WaitForSingleObject", "Ptr", handle, "UInt", waitMs, "UInt")
        if (waitResult = 0)
          break
        if (waitResult != 258)
          throw OSError()
      }

      if (timedOut) {
        this._KillProcessTree(pid)
        DllCall("WaitForSingleObject", "Ptr", handle, "UInt", 5000, "UInt")
        return { exitCode: -1, timedOut: true }
      }

      if (!DllCall("GetExitCodeProcess", "Ptr", handle, "UInt*", exitCode))
        throw OSError()
      return { exitCode: exitCode, timedOut: false }
    } finally {
      DllCall("CloseHandle", "Ptr", handle)
    }
  }

  static _KillProcessTree(pid) {
    comSpec := EnvGet("ComSpec")
    if (comSpec = "")
      throw Error("ComSpec is not set")

    try RunWait(this.Quote(comSpec) " /d /c taskkill /PID " pid " /T /F >nul 2>&1",, "Hide")
  }

  static _WriteRunner(runnerPath, command, stdoutPath, stderrPath) {
    script := "@echo off`r`n"
    script .= "setlocal`r`n"
    script .= command " 1>" this.Quote(stdoutPath) " 2>" this.Quote(stderrPath) "`r`n"
    script .= "exit /b %errorlevel%`r`n"
    FileAppend(script, runnerPath, "UTF-16")
  }

  static _ReadText(path) {
    if (!FileExist(path))
      return ""
    return FileRead(path)
  }

  static _DeleteIfExists(path) {
    try {
      if (path != "" && FileExist(path))
        FileDelete(path)
    }
  }
}
