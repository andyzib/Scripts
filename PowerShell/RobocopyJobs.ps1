#requires -version 5
<#
.SYNOPSIS
Uses Run Space Jobs to create multiple robocopy jobs. Great for speeding up transfers of large datasets. 
 
.DESCRIPTION
Uses Run Space Jobs to create multiple robocopy jobs. Great for speeding up transfers of large datasets. 
 
.PARAMETER Source
Source directory (Same as robocopy's source parameter) 

.PARAMETER Destination
Destination directory (Same as robocopy's destination parameter) 

.PARAMETER LogDir
Directory to write robocopy log files to. 

.PARAMETER MaxJobs
Maximum number of simultaneous jobs. Additional jobs will be queued and executed when a previous job finishes. 

.PARAMETER RobocopyParameters
Optional set the parameters that are passed to Robocopy. Defaults are '/S /E /COPY:DAT /PURGE /MIR /ZB /R:0 /W:0'.
 
.INPUTS
None
 
.OUTPUTS
Log file stored in the directory specified by the LogDir parameter. 
 
.NOTES
Author: Andrew Zbikowski <andrew@zibnet.us>

Version History
- 2017-04-10: Added RobocopyParameters.
- 2017-04-07: Error checking on inputs.
- 2017-04-06: Initial script development
 
.EXAMPLE
PS-Robocopy.ps1 -Source E:\MyFiles -Destination \\Server\MyFiles -LogDir C:\TEMP\Logs\MyFiles -MaxJobs 16
#>

# Enable -Debug, -Verbose Parameters. Write-Debug and Write-Verbose!
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination,
    [Parameter(Mandatory=$true)][string]$LogDir,
    [Parameter(Mandatory=$true)][int]$MaxJobs=10,
    [Parameter()][string]$RobocopyParameters='/S /E /COPY:DAT /PURGE /MIR /ZB /R:0 /W:0'
)

Import-Module PoshRSJob -ErrorAction Stop

# Trim trailing \
$Source = $Source.Trim()
$Destination = $Destination.Trim()
$LogDir = $LogDir.Trim()
$Source = $Source.TrimEnd('\')
$Destination = $Destination.TrimEnd('\')
$LogDir = $LogDir.TrimEnd('\')


# Parameter Validation
if (-Not (Test-Path -Path $Source)) {
    Throw "Source Directory $Source Not Found."
}

if (-Not (Test-Path -Path $Destination)) {
    Throw "Destination Directory $Destination Not Found."
}

if (-Not (Test-Path -Path $LogDir)) {
    Throw "Log Directory $LogDir Not Found."
}

# ISO 8601 Date Format. Accept no substuties! 
$iso8601 = Get-Date -Format s
# Colon (:) isn't a valid character in file names.
$iso8601 = $iso8601.Replace(":","_")

$SubFolders = Get-ChildItem -Path $Source
$RobocopyEXE = 'C:\Windows\System32\Robocopy.exe'

# Using the /L switch to do a Robocopy test run. 
#$RobocopyParameters = '/S /E /COPY:DAT /PURGE /MIR /ZB /R:0 /W:0 /L'
# No /L switch, THIS WILL MAKE CHANGES!!! 
#$RobocopyParameters = '/S /E /COPY:DAT /PURGE /MIR /ZB /R:0 /W:0'

# Append the log file for actual run. /log:$LogFile

<#
$SubFolders | % { 
    $LogFile = $LogDir + "\" + $iso8601 + '_' + $_.Name + ".txt"
    $SourceDir = $Source + '\' + $_.Name
    $DestinationDir = $Destination + '\' + $_.Name
    $ArgumentList = "$SourceDir $DestinationDir $RobocopyParameters /log:$LogFile"

    $LogFile = $iso8601 + '_' + $SubFolder.Name + ".txt"
    Write-Host "Logfile $LogFile"
    Write-Host "Source $SourceDir"
    Write-Host "Destination $DestinationDir"
    Write-Host "Robocopy Arguments: $ArgumentList"
} 
#>

$SubFolders | Start-RSJob -Name { "$($_)" } -ScriptBlock {
    Param($RobocopyEXE,$RobocopyParameters,$LogDir,$Source,$Destination,$iso8601)
    $LogFile = $LogDir + "\" + $iso8601 + '_' + $_.Name + ".txt"
    $SourceDir = $Source + '\' + $_.Name
    $DestinationDir = $Destination + '\' + $_.Name
    $ArgumentList = "$SourceDir $DestinationDir $RobocopyParameters /log:$LogFile"
    # & $RobocopyEXE $Source $Destination $RobocopyParamaters $LogParam
    $p = Start-Process $RobocopyEXE -ArgumentList $ArgumentList -wait -NoNewWindow -PassThru
    # Output of the job, drop it on the Pipeline. 
    New-Object PSObject -Property @{
        Source=$SourceDir
        Destination=$DestinationDir
        LogFile=$LogFile
        ExitCode=$p.ExitCode
    }
} -Throttle $MaxJobs -ArgumentList $RobocopyEXE,$RobocopyParameters,$LogDir,$Source,$Destination,$iso8601 | Wait-RSJob

$result = Get-RSJob | Receive-RSJob
Get-RSJob | Remove-RSJob # Clean out the jobs, don't need them anymore! 
$result | Export-CSV -Path "$LogDir\$($iso8601)_JOB_LOG.csv"