<#
.SYNOPSIS
Load up VMware PowerCLI in a standard PowerShell console.
 
.DESCRIPTION
Just loads VMware PowerCLI.

.NOTES
Just wanted a quick way to get PowerCLI up and running without having to launch the PowerCLI shortcut. 
So I created a quick module to do the work for me. 
Drop in $env:USERPROFILE\Documents\WindowsPowerShell\Modules\vmware
Use: import-module vmware
Use VMware PowerCLI as usual after importing the module. 
#>
 
# Test to see if VMware is installed.
If (Test-Path -Path "${env:ProgramFiles(x86)}\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1") {
    Add-PSsnapin VMware.VimAutomation.Core
    & "${env:ProgramFiles(x86)}\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}
elseif (Test-Path -Path "$env:ProgramFiles\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1") {
    Add-PSsnapin VMware.VimAutomation.Core
    & "$env:ProgramFiles\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}
else {
    Throw "vSphere PowerCLI installation not found."
}
