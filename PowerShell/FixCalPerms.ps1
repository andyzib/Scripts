Get-User -filter {Office -eq 'Corporate'} | ForEach-Object {Set-MailboxFolderPermission $_":\Calendar" -User Default -AccessRights Reviewer} 
Get-User -filter {Office -eq 'Remote'} | ForEach-Object {Set-MailboxFolderPermission $_":\Calendar" -User Default -AccessRights Reviewer} 
Set-MailboxFolderPermission ceo@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
Set-MailboxFolderPermission cmo@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
Set-MailboxFolderPermission cto@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
Set-MailboxFolderPermission cfo@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
Set-MailboxFolderPermission cmedo@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
Set-MailboxFolderPermission mso@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
Set-MailboxFolderPermission coo@example.com":\Calendar" -User Default -AccessRights AvailabilityOnly
