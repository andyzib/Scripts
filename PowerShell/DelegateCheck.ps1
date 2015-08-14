# script to check delegates for a particular mailbox
$UserToCheck = get-mailbox exampleuser
#check what users have access:
$result = $UserToCheck.GrantSendOnBehalfTo
#display results
$result