$SMTPServer = "email.example.com"
$MailFrom = "ADAccountNotifications@example.com"
$MailTo = "ADAccountNotifications@example.com"

$Event=Get-EventLog -LogName "Security" -InstanceId "4767" -Newest 1

$User = $Event.ReplacementStrings[0]
$Domain = $Event.ReplacementStrings[1]

$UnlockBy =  $Event.ReplacementStrings[4]
$UnlockByDomain = $Event.ReplacementStrings[5]

$Computer = $Event.MachineName

$MailSubject= "Account Unlocked: " + $Domain + "\" + $User

$MailBody = "Account Name: " + $Domain + "\" + $User + "`r`n" + "Workstation: " + $Computer + "`r`n" + "Time: " + $Event.TimeGenerated + "`r`n`r`n Unlocked By: " + $UnlockByDomain + "\" + $UnlockBy

Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body $MailBody