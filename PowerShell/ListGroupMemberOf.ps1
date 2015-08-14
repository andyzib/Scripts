Import-Module ActiveDirectory
$name = Read-Host 'Enter Group Name'
$groups = (Get-ADGroup -Identity $name -Properties MemberOf | Select-Object MemberOf).MemberOf | Sort-Object

foreach ($group in $groups) {
	$found = $group -match '^CN=(.+?),OU=.*$'
	if ($found) {
		Write-Host $matches[1]
	}
}