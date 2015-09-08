#requires -version 3
<#
.SYNOPSIS
Retrives server list for a given support group in REFUGE, then verifies that the iLOIPAddress value is an online HP iLO device.
 
.DESCRIPTION
Retrives server list for a given support group in REFUGE, then verifies that the iLOIPAddress value is an online HP iLO device. Requires HP's iLO cmdlets.
 
.PARAMETER SupportGroup
REFUGE support group to retreive. Defaults to SERVER.
 
.OUTPUTS
CSV file stored in $env:USERPROFILE\Documents
 
.NOTES
Version:        0.1
Author:         Andrew Zbikowski <andrew@zibnet.us>
Creation Date:  2015-09-02
Purpose/Change: Initial script development
 
Changes:
* 2015-09-03 @ 10:14: Added a check to make sure iLOIPAddress has a value before feeding it to Find-HPiLO.
* 2015-09-03 @ 12:11: Added a RegEx to clean up iLO IP Address before feeding it to Find-HPiLO.
* 2015-09-04 @ 12:30: Added Clean-IPv4Addresses() to deal with bad data.
* 2015-09-04 @ 14:24: Cleanup of comment based help.
 
.LINK
http://www.hp.com/go/powershell
 
.EXAMPLE
Normal run.
.\iLO_Phase1.ps1
 
.EXAMPLE
Specify support group.
.\iLO_Phase1.ps1 -SupportGroup DMZ-SERVER
#>
 
#-------------[Parameters]-----------------------------------------------------
# Define Parameters
Param (
    [Parameter()][string]$SupportGroup = "SERVER"
)
 
#-------------[Parameter Validation]-------------------------------------------
# Verify $supportgroup is a valid string (under 50 or so characters.)
if ( $SupportGroup.length -gt 50 ) {
    Throw "Invalid REFUGE Support Group: $SupportGroup"
}
#-------------[Initialisations]------------------------------------------------
 
Import-Module hpilocmdlets -ErrorAction Stop
 
# Production REFUGE Web Service
$REFUGE_URI = 'http://REFUGE.example.com:8080/REFUGEServerInfo.svc'
$REFUGE = New-WebServiceProxy $REFUGE_URI -class server -Namespace webservice
# Interesting REFUGE Properties
$REFUGE_Props = @('DeviceName','Domain','FQDN','IPAddress','OSDescription','OSType','ProductNameModel','SupportEnvDescription','SupportStageDescription','iLoIPAddress')
 
# Interesting HP iLO Properties returned by Find-HPiLO
<# Example Find-HPiLO Output
IP           : 192.168.100.100
HOSTNAME     : hpilo.example.com
SPN          : ProLiant DL380 G4
FWRI         : 1.96
PN           : Integrated Lights-Out (iLO)
SerialNumber : ABCDEFGHIJ
UUID         :
#>
$iLO_Props = @('IP','HOSTNAME','SPN','FWRI','PN','SerialNumber','UUID')
 
#-------------[Declarations]---------------------------------------------------
# ISO 8601 Date Format. Accept no substuties! 
$iso8601 = Get-Date -Format s
# Colon (:) isn't a valid character in file names.
$iso8601 = $iso8601.Replace(":","_")
 
#-------------[Functions]------------------------------------------------------
Function Clean-IPv4Addresses ($addresses) {
 
    <# Examples of known bad data in REFUGE inventory.
        00.00.000.00
        0.179.88.242
        0.0.0.0;10.205.227.207
        0.0.0.0;10.204.156.197
        0.0.0.0;10.204.146.114
        0.0.0.0;10.179.56.41;10.179.56.43;10.179.56.44;10.179.56.45
        0.0.0.0;10.179.56.39
        0.0.0.0;10.179.56.37
        10.205.227.207-lo
        0.0.0.0;10.179.56.41-lo;10.179.56.43;10.179.56.44-lo;10.179.56.45
    #>
 
    # Finds all zeros followed by ';': 0.0.0.0;00.000.0.000;
    $pattern = "^(.*)[0]{1,3}\.[0]{1,3}\.[0]{1,3}\.[0]{1,3}\;(.*)$"
    $addresses = $addresses -replace $pattern,'$1$2'
 
    # This matches all zeros: 0.0.0.0, 00.000.0.00, etc.
    $pattern = '^.*[0]{1,3}\.[0]{1,3}\.[0]{1,3}\.[0]{1,3}.*$'
    $addresses = $addresses -replace $pattern,''
 
    # Use a RegEx to get rid of unwated characters in the IP Address.
    # The allowd chracters are number, period, and semicolon.
    $pattern = "[^0-9\.\;]"
    $addresses = $addresses -replace $pattern,''
 
    # Now we should have a single IP address or semicolon seperated lists of IPs.
    # Create an array by splitting on semicolon   
    $addresses = $addresses.Split(';')
   
    # One last check for invalid IP addresses. The '0.179.88.242', '00.179.88.242', '000.179.88.242' cases.
   $new_addresses = @()
    foreach ($address in $addresses) {
        # Goodbye leading zeros.
        $address = $address.TrimStart('0')
        if ($address.StartsWith('.')) {
            Continue # If the IP now starts with period, discard. Go to next loop iteration.
        }
        else {
            $new_addresses += $address # Address appears to be valid, add it to final output.
        }
    }
    # Function return value:
    $new_addresses
}
 
 
#-------------[Execution]------------------------------------------------------
 
<# Pseudocode
 
Logic, flow, etc.
 
Phase 1:
- REFUGE Search for SupportGroup = SERVER
- Loop through results, check iLoIPAddress.
- Pass iLoIPAddress into Find-HPiLO -Range <iLOIPAddress> -Timeout <int>
    - This will take a long time depending on how many iLO hosts. Find-HPiLO establishes individual connections to each host.
    - Maybe clean up the iLOIPAddress and break them up into chunks and test in parallel somehow?
- Write out needed informaiton. Yay!
 
End Pseudocode #>
 
# Obtain list of servers from REFUGE
$serverList = $REFUGE.REFUGEInfoBySupportedBy($SupportGroup)
 
# Array to hold the results.
$iLO_Inventory = @()
 
# Check each REFUGE result for a HP iLO
foreach ($server in $serverList) { # Start Main Loop.
   
    if ($server.iLoIPAddress -eq "") {
        Continue # Continue to next server in the result list. Code after Continue will not be executed.
    }
   
    $iLO_Addresses = Clean-IPv4Addresses($server.iLoIPAddress)
    if ($iLO_Addresses -eq '') {
        Continue # Continue to next server in the result list. Code after Continue will not be executed.
    }
 
    # We have valid data in $iLO_Addresses, but we don't know if it's an HP iLO yet.
    # It also could be mutiple IP Addresses. Prepare for loop recursion.
    foreach ($iLO_Address in $iLO_Addresses) { # Start iLO Address Check Loop
        # Create an object to hold the data we want.
        $custom_server_info = new-object PSObject
 
        # Each $iLO_Address will have corresponding REFUGE server info.
        foreach ($oProp in $REFUGE_Props) { # Start Add REFUGE Data loop
            $custom_server_info | add-member -membertype NoteProperty -name "REFUGE_$oProp" -Value $server.$($oProp)
        } # End Add REFUGE Data loop
       
        # 0 or 1 HP iLO devices will be found for each $iLO_Address.
        $iLO_result = Find-HPiLO $iLO_Address
        if ($iLO_result -eq $null) { # No HP iLO cards found if
            # Add HP iLO info to custom server info.
            foreach ($iLOProp in $iLO_Props) { # Start add HP iLO info loop
                $custom_server_info | add-member -membertype NoteProperty -name "iLO_$iLOProp" -Value "N/A"
            } # End add HP iLO info loop
            Write-Host "No HP iLO found for REFUGE record $($server.DeviceName) for iLO Address $iLO_Address."
        } # End of no HP iLO cards found if
        else { # Found a HP iLO device, add it's info!
            foreach ($iLOProp in $iLO_Props) { # Start add HP iLO Info.
                $custom_server_info | add-member -membertype NoteProperty -name "iLO_$iLOProp" -Value $iLO_result.$($iLOProp)
            } # End add HP iLO Info
            Write-Host "Found $($iLO_result.PN) for REFUGE record $($server.DeviceName) at IP Address $($iLO_result.IP)"
        } # End of adding HP iLO device.
    } # End iLO Address Check Loop
    $iLO_Inventory += $custom_server_info  
    # FIXME: Remove this, just writing every 100 records or so to verify results.
    $checkpoint = 2500
    if ($iLO_Inventory.Count % $checkpoint -eq 0 ) {
        $outfile = $env:USERPROFILE + "\Documents\" + $iso8601 + "_iLO_Inventory_Checkpoint" + $iLO_Inventory.Count + ".csv"
        $iLO_Inventory | export-csv -Path $outfile -NoTypeInformation
        Write-Host "===> Checkpoint file $outfile containing $($iLO_Inventory.Count) written. <==="
    }
} # End of Main Loop
 
$outfile = $env:USERPROFILE + "\Documents\" + $iso8601 + "_iLO_Inventory.csv"
$iLO_Inventory | export-csv -Path $outfile -NoTypeInformation