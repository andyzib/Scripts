# source: http://social.technet.microsoft.com/Forums/exchange/en-US/a234ba3b-37b4-4333-8954-5f46885c5e20/how-to-list-email-addresses-and-aliases-for-each-user
#get mailboxes and iterate through each email address and shows it either primary or an alias

get-mailbox |Where{$_.HiddenFromAddressListsEnabled -eq $false} | foreach{ 

 $host.UI.Write("Blue", $host.UI.RawUI.BackGroundColor, "`nUser Name: " + $_.DisplayName+"`n")

 for ($i=0;$i -lt $_.EmailAddresses.Count; $i++)
 {
    $address = $_.EmailAddresses[$i]
    
    $host.UI.Write("Blue", $host.UI.RawUI.BackGroundColor, $address.AddressString.ToString()+"`t")
 
    if ($address.IsPrimaryAddress)
    { 
    	$host.UI.Write("Green", $host.UI.RawUI.BackGroundColor, "Primary Email Address`n")
    }
   else
   {
    	$host.UI.Write("Green", $host.UI.RawUI.BackGroundColor, "Alias`n")
    }
 }
}

	