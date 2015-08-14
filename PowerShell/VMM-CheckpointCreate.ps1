param([string]$vm = $null)

if (!$vm) { 
	Write-Host "No VM specified!"
	exit
}

# Virtual Machine Manager Server. 
$VMMServer = "SCVMM01.example.local"

$desc = "Scripted Snapshot"
Get-VM -VMMServer $VMMServer -Name $vm | New-VMCheckpoint -Description $desc