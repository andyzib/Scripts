$folderPath = "\\filer0b\Teams\applications"
$fileName = "~"
$DeletedFiles = "C:\TEMP\filer0b_DeletedFiles.txt"
$ErrorLog = "C:\TEMP\filer0b_ScriptErrors.txt"
 
Get-ChildItem -Recurse -Force $folderPath -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and ( $_.Name -like "$fileName*") } | ForEach-Object { 
	$FilePath = $_.fullname 
	Try
	{
		Remove-Item -Path $FilePath -Force
		$FilePath | Add-Content $DeletedFiles
	}
	Catch
	{
		"ERROR moving $filename: $_" | Add-Content $ErrorLog
	}
}
# end of the script