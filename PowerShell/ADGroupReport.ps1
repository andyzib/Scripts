#requires -version 3
<#
.SYNOPSIS
Creates a report of group membership from a list of AD usernames. 

.DESCRIPTION
Creates a report of group membership from a list of AD usernames. 

.PARAMETER csv
REQUIRED: Path to CSV file. Script expects CSV file to have Primary and Secondary ID columns.

.PARAMETER PrimaryIDHeader
OPTIONAL: Header of the column with list of primary IDs.
DEFAULT: PrimaryID

.PARAMETER SecondaryIDHeader
OPTIONAL: Header of the column with list of Secondary IDs.
DEFAULT: SecondaryID

.PARAMETER outdir
OPTIONAL: Path to write output report(s) to.
DEFAULT: $env:USERPROFILE)\Documents

.OUTPUTS
Saves a CSV file to <outdir>

.NOTES
Author:         Andrew Zbikowski <andyzib@gmail.com>
v0.1 changes, 2015-11-09
* Initial script development

.EXAMPLE
STANDARD RUN:
.\ADGroupsReport.ps1 -csv C:\Users\username\Documents\IDList.csv

.EXAMPLE
CSV file has headers that are different from default:
.\ADGroupsReport.ps1 -csv IDList.csv -PrimaryIDHeader Primary_ID -SecondaryIDHeader Secondary_ID
#>
#-------------[Parameters]-----------------------------------------------------
# Enable -Debug, -Verbose Parameters. Write-Debug and Write-Verbose!
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][string]$csv = $( Read-Host "Enter path and filename to CSV file"),
    [Parameter()][string]$PrimaryIDHeader = "PrimaryID",
    [Parameter()][string]$SecondaryIDHeader = "SecondaryID",
    [Parameter()][string]$outdir = "$($env:USERPROFILE)\Documents"
    #[Parameter()][switch]$PrimaryIDs = $true,
    #[Parameter()][switch]$SecondaryIDs = $true
)
#-------------[Parameter Validation]-------------------------------------------
# Sanitize User Input
# Check that the CSV file exists.
if (-Not (Test-Path -PathType Leaf -Path $csv)) {
    Throw "CSV not found: $csv"
}

# Try to read CSV file.
Try { $csvdata = Import-Csv -Path $csv | Sort-Object vCenter }
Catch { Throw "Unable to read CSV file $csv." }

# Check that the CSV contains the expected headers.
$arrHeaders = (Get-Content $csv | Select-Object -First 1).Split(",")
if ( $arrHeaders -notcontains $PrimaryIDHeader ) { Throw "$csv does not have a column named $PrimaryIDHeader"}
if ( $arrHeaders -notcontains $SecondaryIDHeader ) { Throw "$csv does not have a column named $SecondaryIDHeader"}

# Strip trailing \ from $outdir
$outdir = $outdir.Trim()
$outdir = $outdir.TrimEnd("\")

# Check that outdir exists.
if (-Not (Test-Path -PathType Container -Path $outdir)) {
    Throw "Output directory note found: $outdir"
}
#-------------[Initialisations]------------------------------------------------
Import-Module activedirectory -ErrorAction Stop
#-------------[Declarations]---------------------------------------------------
# ISO 8601 Date Format. Accept no substuties! 
$iso8601 = Get-Date -Format s
# Colon (:) isn't a valid character in file names.
$iso8601 = $iso8601.Replace(":","_")
# Just YYYY-MM-DD
#$datestamp = $iso8601.Substring(0,10)

# Build the path to the output file.
# Build the output file.
$outfile = $outdir + "\GroupMembers_" + $iso8601 + ".csv"

<#
Required CSV headers:
SecondaryID,PrimaryID
#>

# List of interesting Active Directory properties.
$adprops = @("employeeType","SamAccountName","Surname","GivenName","EmployeeID","mail","Manager","Title","Company","Office","City","State","co","memberOf")
# Shorter list of interesting Active Directory properties for managers.
$mgrprops = @("SamAccountName","Surname","GivenName","EmployeeID","mail")

#-------------[Functions]------------------------------------------------------
# The AD User Property MemberOf will be a multiline string of Distinguised Names.
# Parseout the Display Names and return the string in the desitred format.
Function Cleanup-MemberOf($groups) {
    $arrGroups = $groups -Split '`n'
    #RegEx to get just the display name (everything between first CN= and first comma)
    $pattern = '^CN=(.*?),.*$'
    foreach ($thing in $arrGroups) {
        $return += $thing -replace $pattern,'$1'
        $return += "`n"
    }
    $return
}

Function Build-ResultObject {
    Param (
        [Parameter()]$ADUserInfo,
        [Parameter()]$ADMngrInfo,
        [Parameter()]$ADGroups
    )
    $return = new-object PSObject
    foreach ($user_prop in $adprops){
        # Exclude the memberOf propery here, the customized version is what we want written.
        if ($user_prop -ne 'memberOf') {
            $return | add-member -membertype NoteProperty -name "$user_prop" -Value $ADUserInfo.$($user_prop)
        }
    }
    foreach ($mgr_prop in $mgrprops){
        $return | add-member -Force -membertype NoteProperty -name "manager_$mgr_prop" -Value $ADMngrInfo.$($mgr_prop)
    }
    $return | add-member -membertype NoteProperty -name "MemberOf" -Value $ADGroups
    # Put the return object on the pipeline.
    $return
}
#-------------[Execution]------------------------------------------------------
<# Pseudocode
* Read in CSV file
* Loop through each CSV file.
* Get AD Properties for each ID.
* Get AD Group Membership for each ID.
* Format Group Membership for CSV output. (Seperate by newline of semicolon?)
* Add results to a CSV file.
* Done!
End Pseudocode #>

# All results.
$resultsarray =@()
foreach ($line in $csvdata) {
    # Get AD User and Manager info for PrimaryID
    $ADUserInfo_Primary = Get-ADUser -Identity $line.$($PrimaryIDHeader) -Properties $adprops
    $ADMngrInfo_Primary = Get-ADUser -Identity $($ADUserInfo_Primary.Manager) -Properties $mgrprops

    # Get AD User and Manager info for SecondaryID
    $ADUserInfo_Secondary = Get-ADUser -Identity $line.$($SecondaryIDHeader) -Properties $adprops
    $ADMngrInfo_Secondary = Get-ADUser -Identity $($ADUserInfo_Secondary.Manager) -Properties $mgrprops

    # Format group membership
    $ADGroups_Primary = Cleanup-MemberOf $ADUserInfo_Primary.MemberOf
    $ADGroups_Secondary = Cleanup-MemberOf $ADUserInfo_Secondary.MemberOf

    # Add to results array.
    $resultsarray += Build-ResultObject -ADUserInfo $ADUserInfo_Primary -ADMngrInfo $ADMngrInfo_Primary -ADGroups $ADGroups_Primary
    $resultsarray += Build-ResultObject -ADUserInfo $ADUserInfo_Secondary -ADMngrInfo $ADMngrInfo_Secondary -ADGroups $ADGroups_Secondary
}

# Write output
$resultsarray | Export-Csv $outfile -NoTypeInformation
Write-Output "Results written to $outfile. Have a great day!" 