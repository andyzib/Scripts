# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support

$MailboxServer = Get-MailboxDatabase -Identity DB1 | Get-MailboxDatabaseCopyStatus | Where-Object {$_.ActiveCopy -eq $true} 
$MailboxServer = $MailboxServer.MailboxServer

IF ($MailboxServer -eq "ex02")
{
	Move-ActiveMailboxDatabase -Identity 'DB1' -ActivateOnServer 'ex01' -MountDialOverride 'None' -confirm:$false
	$SMTPServer = "email.example.com"
	$MailFrom = "RobotB9@example.com"
	$MailTo = "corpsys-alerts@example.com"
	$MailBody = "Ran Move-ActiveMailboxDatabase -Identity 'DB1' -ActivateOnServer 'ex01' -MountDialOverride 'None'"
	$MailSubject = "Activated Mailbox Database DB1 on EX01"
	Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body $MailBody
}
