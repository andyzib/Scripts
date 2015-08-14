# This will reset the Out of Office state for the configured 
# mailboxes. This clears the history so that anyone sending 
# mail to these mailboxes will get another out of office 
# reply. 

#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin 
# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support

Set-MailboxAutoReplyConfiguration -Identity devnull -AutoReplyState Disabled
Set-MailboxAutoReplyConfiguration -Identity devnull -AutoReplyState Enabled

Set-MailboxAutoReplyConfiguration -Identity tier2 -AutoReplyState Disabled
Set-MailboxAutoReplyConfiguration -Identity tier2 -AutoReplyState Enabled