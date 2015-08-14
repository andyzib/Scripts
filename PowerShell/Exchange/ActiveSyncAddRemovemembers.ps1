######################################################################## 
##Adapted from original script found at
##http://gallery.technet.microsoft.com/scriptcenter/ActiveSync-enable-disable-e67fa983
######################################################################## 
#
########################################################################
##This script reads user membership of several approved groups in AD and enables or disables ActiveSync
##accordingly. This script also performs the same for POP3 access, but the summary email does not
##include those accounts.
########################################################################

##Add Exchange Snap In to execute Exchange Cmdlets in this script 
# For Exchange 2007
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin 
# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support

##Establish Approved user arrays## 
$CorpASDLname = "ACL-ActiveSync-Enabled" 
$CorpActiveSyncUsers =  Get-distributionGroupmember -ResultSize unlimited -id $CorpASDLname

##Import Device listing for email report##
$knowndevices = @{}
#Import-Csv c:\powershellscripts\knowndevices.csv | foreach {$knowndevices[$_.AgentString] = $_.DeviceName}

##Establish empty variables##
$allactivesyncusers = @()
$activeUserInfo = @()

##Establish other misc variables##
$allmbx = get-mailbox -resultsize unlimited
$report = "c:\powershellscripts\report.htm"
$recentDeviceDate = [DateTime]::Today.AddDays(-45)

##Combine ActiveSync groups for comparison to non-approved users##
foreach ($user in $CorpActiveSyncUsers) {$allactivesyncusers += $user}
$allactivesyncusers = $allactivesyncusers | select -uniq

##Count all mailboxes for comparison and approved users for email report##
$sync = ($allmbx).count
$usercount = ($allactivesyncusers).count

##Enables approved ActiveSync users and disables everyone else##
$notapproved = compare-object -referenceobject $allmbx -differenceobject $allActivesyncusers -Property "Name" -syncwindow $sync
$notapproved | foreach {
		get-mailbox $_.name | set-casmailbox -activesyncenabled:$false -IMAPenabled $false -popenabled $false
}

##Loop through the array of corporate approved users##
foreach ($member in $CorpActiveSyncUsers) {
 
       # Set ActiveSync for each member of the array
       $member | Set-CASMailbox –ActiveSyncEnabled $true -ActiveSyncMailboxPolicy "Default" -IMAPenabled $false -popenabled $false
}

##Get Active Sync information for all approved users##
foreach ($user in $allactivesyncusers) {
	$casinfo = Get-Casmailbox ($user).get_Identity()
	if ($casinfo.HasActiveSyncDevicePartnership -eq $False) {
		$userobject = New-Object system.Object
		$userobject | Add-Member -type Noteproperty -Name DisplayName -Value $casinfo.DisplayName
		$userobject | Add-Member -type Noteproperty -Name ActiveSyncMailboxPolicy -Value $casinfo.ActiveSyncMailboxPolicy
		$userobject | Add-Member -type Noteproperty -Name Device -Value "Not Activated"
		$userobject | Add-Member -type Noteproperty -Name LastCheckin -Value $null
		$activeUserInfo = $activeUserInfo + $userobject
		}
	elseif ($casinfo.HasActiveSyncDevicePartnership -eq $True) {
		$deviceList = get-activesyncdevicestatistics -mailbox ($user).get_Identity()
		$recentdevicecount = 0
		foreach ($device in $deviceList) {
			if (($device.LastSuccessSync -gt $recentDeviceDate) -and ($device.DeviceUserAgent -notmatch "Server")) {
				$userobject = New-Object system.Object
				$userobject | Add-Member -type Noteproperty -Name DisplayName -Value $casinfo.DisplayName
				$userobject | Add-Member -type Noteproperty -Name ActiveSyncMailboxPolicy -Value $casinfo.ActiveSyncMailboxPolicy
				$device_key = $knowndevices.keys | where {$device.DeviceUserAgent -match $_}
				if ($device_key){
					$userobject | Add-Member -type Noteproperty -Name Device -Value $knowndevices.$device_key
				}
				else {
					$userobject | Add-Member -type Noteproperty -Name Device -Value $device.DeviceUserAgent
				}
				$userobject | Add-Member -type Noteproperty -Name LastCheckin -Value $device.LastSuccessSync
				$activeUserInfo = $activeUserInfo + $userobject
				$recentdevicecount++
				}
		}
		if ($recentdevicecount -eq 0) {
			$userobject = New-Object system.Object
			$userobject | Add-Member -type Noteproperty -Name DisplayName -Value $casinfo.DisplayName
			$userobject | Add-Member -type Noteproperty -Name ActiveSyncMailboxPolicy -Value $casinfo.ActiveSyncMailboxPolicy
			$userobject | Add-Member -type Noteproperty -Name Device -Value "No recent devices"
			$activeUserInfo = $activeUserInfo + $userobject
		}
	}
}

#Sort array by Name
$activeUserInfo = $activeUserInfo | Sort-Object DisplayName

##Clears the report in case there is data in it
Clear-Content $report
##Builds the headers and formatting for the report
Add-Content $report "<html>" 
Add-Content $report "<head>" 
Add-Content $report "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>" 
Add-Content $report '<title>COMPANY ActiveSync Report</title>' 
add-content $report '<STYLE TYPE="text/css">' 
add-content $report  "<!--" 
add-content $report  "td {" 
add-content $report  "font-family: Tahoma;" 
add-content $report  "font-size: 11px;" 
add-content $report  "border-top: 1px solid #999999;" 
add-content $report  "border-right: 1px solid #999999;" 
add-content $report  "border-bottom: 1px solid #999999;" 
add-content $report  "border-left: 1px solid #999999;" 
add-content $report  "padding-top: 0px;" 
add-content $report  "padding-right: 0px;" 
add-content $report  "padding-bottom: 0px;" 
add-content $report  "padding-left: 0px;" 
add-content $report  "}" 
add-content $report  "body {" 
add-content $report  "margin-left: 5px;" 
add-content $report  "margin-top: 5px;" 
add-content $report  "margin-right: 0px;" 
add-content $report  "margin-bottom: 10px;" 
add-content $report  "" 
add-content $report  "table {" 
add-content $report  "border: thin solid #000000;" 
add-content $report  "}" 
add-content $report  "-->" 
add-content $report  "</style>" 
Add-Content $report "</head>" 
add-Content $report "<body>" 

##This section adds tables to the report with individual content
##Table 1 for enabled users
add-content $report  "<table width='100%'>" 
add-content $report  "<tr bgcolor='#CCCCCC'>" 
add-content $report  "<td colspan='7' height='25' align='center'>" 
add-content $report  "<font face='tahoma' color='#003399' size='4'><strong>The following $usercount devices are enabled for ActiveSync</strong></font>" 
add-content $report  "</td>" 
add-content $report  "</tr>" 
add-content $report  "</table>" 
add-content $report  "<table width='100%'>" 
Add-Content $report "<tr bgcolor=#CCCCCC>" 
Add-Content $report  "<td width='20%' align='center'>Account Name</td>" 
Add-Content $report "<td width='30%' align='center'>ActiveSync Policy</td>"  
Add-Content $report "<td width='30%' align='center'>Devices seen in the last 45 days</td>"
Add-Content $report "<td width='15%' align='center'>Last Checkin</td>"
Add-Content $report "</tr>" 
if ($activeUserInfo -ne $null){
	foreach ($name in $activeUserInfo) {
		$AccountName = $name.Displayname
		$Policy = $name.ActiveSyncMailboxPolicy
		$Device = $name.Device
		$Checkin = $name.LastCheckIn
		Add-Content $report "<tr>" 
		Add-Content $report "<td>$AccountName</td>" 
		Add-Content $report "<td>$Policy</td>" 
		Add-Content $report "<td>$Device</td>"
		Add-Content $report "<td>$Checkin</td>"
	}
}
else {
	Add-Content $report "<tr>" 
	Add-Content $report "<td>No Accounts match</td>" 
}
Add-content $report  "</table>" 

##This section closes the report formatting
Add-Content $report "</body>" 
Add-Content $report "</html>" 

##Assembles and sends completion email with DL information##
$emailFrom = "MAILSERVER@example.com"
$subject = "ActiveSync Report"
$smtpServer = "email.example.com"
$body = Get-Content $report | Out-String

##Assembles and sends completion email with DL information##
$mail = New-Object System.Net.Mail.MailMessage
$mail.IsBodyHtml = $true
$mail.From = $emailFrom
$mail.To.Add("helpdesk@example.com")
$mail.subject = $subject
$mail.Body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

$smtp.Send($mail)

get-mailbox mbsplunk@example.com | set-casmailbox -activesyncenabled:$false -IMAPenabled $true -popenabled $true
