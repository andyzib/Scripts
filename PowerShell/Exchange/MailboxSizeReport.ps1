#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin 
# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support

# Format a date stamp
$today = get-date
$datestamp = $today.toString('yyyy-MM-dd')

# Create Report
Get-MailboxStatistics -Database "db1" | Select DisplayName, ItemCount, TotalItemSize | Sort-Object TotalItemSize -Descending | Export-CSV \\server\share\ExchangeReports\MailboxSizeReport_$datestamp.csv

# That's it. 
