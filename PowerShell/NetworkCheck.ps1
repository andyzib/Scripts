# Check that the network is rechable on Linux KVM machines. If not,
# disable the NIC, wait 30 seconds, and enable the NIC again. 
# If the computer is online, send a notification email.
# Created by Andrew Zbikowski. <andrew@zibnet.us>
# Version: 2013-07-08_01

# Network adapter service name. Use get-WmiObject win32_networkadapter | fl to find this. 
# netkvm for RHEL KVM
$serviceName = "netkvm"
# E1G60 for VMware Fusion
#$serviceName = "E1G60"

# Ping this computer/IP address to test connectivity. 
$pingHost = "10.10.25.1"

# Ping Count, number of times to ping $pingHost
$pingCount = 4

#SMTP server name
$smtpServer = "email.example.com"

# Email From
$emailFrom = "Robot B-9 <noreply@example.com>"

# Email To
$emailTo = "techops-it-alerts@example.com"

function sendMail{
	$computer = gc env:computername
	
	#Creating a Mail object
	$msg = new-object Net.Mail.MailMessage

	#Creating SMTP server object
	$smtp = new-object Net.Mail.SmtpClient($smtpServer)

	#Email structure
	$msg.From = $emailFrom
	$msg.ReplyTo = $emailFrom
	$msg.To.Add($emailTo)
	$msg.subject = "Network Connection Restarted on $computer"
	$msg.body = "Network connectivity was lost on $computer. NIC on $computer was restarted and connectivity has been restored."

	#Sending email
	$smtp.Send($msg)
}


If (-Not(Test-Connection $pingHost -count 4 -quiet)) {
	$Ethernet = get-WmiObject win32_networkadapter |where { $_.ServiceName -like "*$serviceName*"}
	$Ethernet.Disable()
	Start-Sleep -s 30
	$Ethernet.Enable()
	Start-Sleep -s 30
	If (Test-Connection $pingHost -count 4 -quiet) {
		sendMail
	}
}


