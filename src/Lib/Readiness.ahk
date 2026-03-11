class Readiness {
  static Validate(cfg, contractPath, dryRun := false) {
    if (!FileExist(contractPath))
      throw Error("Readiness contract not found: " contractPath)

    this.ValidateSection(cfg, contractPath, "always")
    if (!dryRun)
      this.ValidateSection(cfg, contractPath, "full")
    if (cfg.HasOwnProp("email") && cfg.email.HasOwnProp("enabled") && cfg.email.enabled)
      this.ValidateSection(cfg, contractPath, "email")
  }

  static ValidateSection(cfg, contractPath, sectionName) {
    index := 1
    loop {
      rule := Trim(IniRead(contractPath, sectionName, index, ""))
      if (rule = "")
        break

      parts := StrSplit(rule, "|")
      if (parts.Length < 3)
        throw Error("Invalid readiness rule: " rule)

      keyPath := Trim(parts[1])
      kind := Trim(parts[2])
      message := Trim(parts[3])
      valueText := this.GetValueText(cfg, keyPath)

      if (this.RuleFails(kind, valueText))
        throw Error(this.FormatMessage(message, keyPath, valueText))

      index += 1
    }
  }

  static GetValueText(cfg, keyPath) {
    parts := StrSplit(keyPath, ".")
    if (parts.Length != 2)
      throw Error("Unsupported readiness key path: " keyPath)

    sectionName := parts[1]
    keyName := parts[2]

    if (!cfg.HasOwnProp(sectionName))
      return ""

    section := cfg.%sectionName%
    if (!IsObject(section) || !section.HasOwnProp(keyName))
      return ""

    value := section.%keyName%
    return value ""
  }

  static RuleFails(kind, valueText) {
    valueText := Trim(valueText)

    if (kind = "required-value")
      return valueText = ""

    if (kind = "required-dir") {
      if (valueText = "")
        return false
      return !DirExist(valueText)
    }

    if (kind = "required-file") {
      if (valueText = "")
        return false
      return !FileExist(valueText)
    }

    if (kind = "required-env") {
      if (valueText = "")
        return false
      return EnvGet(valueText) = ""
    }

    throw Error("Unknown readiness rule type: " kind)
  }

  static FormatMessage(message, keyPath, valueText) {
    result := StrReplace(message, "{key}", keyPath)
    result := StrReplace(result, "{value}", valueText)
    return result
  }
}
