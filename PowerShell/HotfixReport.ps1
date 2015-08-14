$computer = Read-Host 'What computer do you want a hotfix report for?'
get-hotfix -ComputerName $computer | Sort-Object InstalledOn | Select InstalledOn,Caption,CSName,Description,HotFixID,InstalledBy | export-csv -NoTypeInformation Get-Hotfix_$computer.csv