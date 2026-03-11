param(
  [Parameter(Mandatory=$true)][string]$SmtpHost,
  [Parameter(Mandatory=$true)][int]$SmtpPort,
  [Parameter(Mandatory=$true)][bool]$UseSsl,
  [Parameter(Mandatory=$true)][string]$From,
  [Parameter(Mandatory=$true)][string]$To,
  [Parameter(Mandatory=$true)][string]$User,
  [Parameter(Mandatory=$true)][string]$PasswordEnv,
  [Parameter(Mandatory=$true)][string]$Subject,
  [Parameter(Mandatory=$true)][string]$Body
)

$password = [Environment]::GetEnvironmentVariable($PasswordEnv)
if ([string]::IsNullOrWhiteSpace($password)) {
  throw "Missing SMTP password env: $PasswordEnv"
}

$secure = ConvertTo-SecureString $password -AsPlainText -Force
$password = $null
$cred = New-Object System.Management.Automation.PSCredential($User, $secure)

$smtp = New-Object System.Net.Mail.SmtpClient($SmtpHost, $SmtpPort)
$smtp.EnableSsl = $UseSsl
$smtp.Credentials = $cred

$msg = New-Object System.Net.Mail.MailMessage($From, $To, $Subject, $Body)
$smtp.Send($msg)
