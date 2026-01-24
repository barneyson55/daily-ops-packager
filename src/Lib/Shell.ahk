class Shell {
  static Quote(arg) {
    if (arg = "")
      return '""'
    return '"' StrReplace(arg, '"', '""') '"'
  }

  static Exec(command, workDir := "", logOutput := false) {
    shell := ComObjCreate("WScript.Shell")
    if (workDir != "")
      shell.CurrentDirectory := workDir
    exec := shell.Exec(command)
    while (exec.Status = 0)
      Sleep 50
    stdout := ""
    stderr := ""
    if (!exec.StdOut.AtEndOfStream)
      stdout := exec.StdOut.ReadAll()
    if (!exec.StdErr.AtEndOfStream)
      stderr := exec.StdErr.ReadAll()
    if (!logOutput) {
      stdout := ""
      stderr := ""
    }
    return { exitCode: exec.ExitCode, stdout: stdout, stderr: stderr }
  }
}
