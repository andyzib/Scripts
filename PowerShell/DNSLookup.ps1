Function Resolve-DNS {
    Param(
        [Parameter(Mandatory=$true)] $IPAddress
    )
    Return New-Object PSObject -Property @{
        IP = $IPAddress
        FQDN = [System.Net.Dns]::GetHostEntry($IPAddress).HostName
        Hostname = ([System.Net.Dns]::GetHostEntry($IPAddress).HostName).split(".")[0]
    }
}