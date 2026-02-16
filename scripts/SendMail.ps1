param(
  [Parameter(Mandatory=$true)][string]$SmtpHost,
  [Parameter(Mandatory=$true)][int]$SmtpPort,
  [Parameter(Mandatory=$true)][bool]$UseSsl,
  [Parameter(Mandatory=$true)][string]$From,
  [Parameter(Mandatory=$true)][string]$To,
  [Parameter(Mandatory=$true)][string]$User,
  [Parameter(Mandatory=$true)][string]$Password,
  [Parameter(Mandatory=$true)][string]$Subject,
  [Parameter(Mandatory=$true)][string]$Body
)

$secure = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($User, $secure)

$smtp = New-Object System.Net.Mail.SmtpClient($SmtpHost, $SmtpPort)
$smtp.EnableSsl = $UseSsl
$smtp.Credentials = $cred

$msg = New-Object System.Net.Mail.MailMessage($From, $To, $Subject, $Body)
$smtp.Send($msg)
