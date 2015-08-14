# Source: http://community.spiceworks.com/how_to/show/4212-scripting-getting-all-mail-fordwards-in-exchange-2010
# get all mailboxes that have a forward, sort by name and select their name and forward address
$fwds = get-mailbox | Where-Object { $_.ForwardingAddress -ne $null } | sort Name | select Name, ForwardingAddress

# now get the primary smtp adress of each forward address
foreach ($fwd in $fwds) {
$fwd | add-member -membertype noteproperty -name "ContactAddress" -value (get-Recipient $fwd.ForwardingAddress).PrimarySmtpAddress
}

# finally excport to a CSV without the annoying type header
$fwds | Export-Csv U:\forwards.csv -NoTypeInformation 
Write-Host "Results saved to U:\forwards.csv"