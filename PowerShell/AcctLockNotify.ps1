#$Event=get-eventlog -log security | where {$_.eventID -eq 4740} | Sort-Object index -Descending | select -first 1

$SMTPServer = "email.example.com"
$MailFrom = "ADAccountNotifications@example.com"
$MailTo = "ADAccountNotifications@example.com"

Import-Module activedirectory

$Event=Get-EventLog -LogName "Security" -InstanceId "4740" -Newest 1

$User = $Event.ReplacementStrings[0]

$Computer = $Event.ReplacementStrings[1]

$Domain = $Event.ReplacementStrings[5]

$MailSubject= "Account Locked Out: " + $Domain + "\" + $User

$MailBody = "Account Name: " + $Domain + "\" + $User + "`r`n" + "Workstation: " + $Computer + "`r`n" + "Time: " + $Event.TimeGenerated + "`r`n"

$lockedAccounts = Search-ADAccount -LockedOut | Select -Property SamAccountName | Out-String

$MailBody = $MailBody + "`r`nThe following accounts are currently locked out:`r`n" +  $lockedAccounts

Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -SmtpServer $SMTPServer -Body $MailBody