$name = Read-Host 'What email address are you looking for?'
get-recipient -results unlimited | where {$_.emailaddresses -match $name} | select name,emailaddresses,recipienttype