# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support

$MailboxServer = Get-MailboxDatabase -Identity DB1 | Get-MailboxDatabaseCopyStatus | Where-Object {$_.ActiveCopy -eq $true} 
$MailboxServer = $MailboxServer.MailboxServer

IF ($MailboxServer -eq "VCORP107W")
{
	Move-ActiveMailboxDatabase -Identity 'DB1' -ActivateOnServer 'VCORP100W' -MountDialOverride 'None'
	$SMTPServer = "email.example.com"
	$MailFrom = "RobotB9@example.com"
	$MailTo = "corpsys-alerts@example.com"
	$MailBody = "Ran Move-ActiveMailboxDatabase -Identity 'DB1' -ActivateOnServer 'VCORP100W' -MountDialOverride 'None' after VCORP100W has been online for 15 minutes."
	$MailSubject = "Activated Mailbox Database DB1 on VCORP100W"
	Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body $MailBody
}
