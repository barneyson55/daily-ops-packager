class Report {
  static WriteDaily(baseDir, data) {
    logDir := baseDir "\\logs"
    DirCreate(logDir)
    date := FormatTime(, "yyyyMMdd")
    reportPath := logDir "\\summary_" date ".csv"

    if (!FileExist(reportPath)) {
      header := "timestamp,status,fileCount,archivePath,zipExit,verifyExit,uploadExit,message`n"
      FileAppend(header, reportPath)
    }

    ts := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    line := this.Csv(ts) . "," . this.Csv(data.status) . "," . this.Csv(data.fileCount) . "," . this.Csv(data.archivePath) . "," . this.Csv(data.zipExit) . "," . this.Csv(data.verifyExit) . "," . this.Csv(data.uploadExit) . "," . this.Csv(data.message) . "`n"
    FileAppend(line, reportPath)
  }

  static Csv(val) {
    if (val = "")
      val := ""
    s := val ""
    q := Chr(34)
    s := StrReplace(s, q, q q)
    return q s q
  }
}
