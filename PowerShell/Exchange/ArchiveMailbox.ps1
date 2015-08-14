##Add Exchange Snap In to execute Exchange Cmdlets in this script 
# For Exchange 2007
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin 
# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support

function Get-DisconnectedMailbox {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [System.String]
        $Name = '*'
    )

    $mailboxes = Get-MailboxServer
    $mailboxes | %{
        $disconn = Get-Mailboxstatistics -Server $_.name | ?{ $_.DisconnectDate -ne $null }
        $disconn | ?{$_.displayname -like $Name} |
            Select DisplayName,
            @{n="StoreMailboxIdentity";e={$_.MailboxGuid}},
            Database
    }
}

function Remove-DisconnectedMailbox {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0, ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
        [System.String]
        $StoreMailboxIdentity,
        [Parameter(Position=1, ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
        [System.String]
        $Database
        )

    process {
        Remove-Mailbox @PSBoundParameters
    }
}

# Get the user's Distinguished Name 
Function Get-DistinguishedName ($strUserName) 
{  
   $searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]'') 
   $searcher.Filter = "(&(objectClass=User)(samAccountName=$strUserName))" 
   $result = $searcher.FindOne() 
 
   Return $result.GetDirectoryEntry().DistinguishedName 
} 


$Name= Read-Host "Please enter a mailbox to archive"

# Save the display name for later so we can delete the mailbox. 
$strDN = Get-DistinguishedName $Name 
$strDN -match "CN=(.+?),OU=.*"
$displayName = $matches[1]

New-MailboxExportRequest -Mailbox $Name -FilePath \\server\E$\ExchangeExports\$Name.pst

while ((Get-MailboxExportRequest -Mailbox $Name | Where {$_.Status -eq "Queued" -or $_.Status -eq "InProgress"}))
{
	sleep 60
}

Get-MailboxExportRequest -Mailbox $Name | Remove-MailboxExportRequest -Confirm:$false 

# This permenatly deletes a disconnected mailbox. Make sure the export command worked! 
if (test-path ("\\server\E$\ExchangeExports\$Name.pst")) 
{
	# Remove Mailbox but not AD account
	# This disconnects the mailbox and puts it into disabled state. 
	Disable-Mailbox -Identity $Name -Confirm:$false 
	Get-DisconnectedMailbox($displayName) | Remove-DisconnectedMailbox -Confirm:$false 
}




 
