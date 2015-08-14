$myexe = "C:\Program Files\7-Zip\7z.exe"
$myparams = ' a -tzip -r '
cd "E:\Shares\CasperShare\Packages"
Get-ChildItem "E:\Shares\CasperShare\Packages" | where {$_.Attributes -eq 'Directory'} | ForEach-Object { 
	$outfile = $_.Name + ".zip"
	Write-Host $myexe a -r -tzip $outfile $_.Name
	&  $myexe a -r -tzip $outfile $_.Name
}