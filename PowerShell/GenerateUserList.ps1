# Generates a CSV file with directory information for RedBrick Health accounts. 
# Modify the columns in the CSV by updating the $myPropertied variable. 
# The useful fields are: "SamAccountName","GivenName","Surname","DisplayName","Title","Company","Department","EmailAddress","OfficePhone","MobilePhone","Fax","HomePhone","StreetAddress","City","State","PostalCode","Country","HomePage","Manager"

Import-Module activedirectory

$myFilter = {Enabled -eq $True -and sAMAccountName -notlike '*admin*' -and sAMAccountName -notlike '*mailbox*' -and sAMAccountName -notlike '*service*'}
#$myProperties = "SamAccountName","GivenName","Surname","DisplayName","Title","Company","Department","EmailAddress","OfficePhone","MobilePhone","Fax","HomePhone","StreetAddress","City","State","PostalCode","Country","HomePage","Manager"
$myProperties = "SamAccountName","GivenName","Surname","DisplayName","EmailAddress","OfficePhone","MobilePhone","HomePhone"
$myDesktop = [Environment]::GetFolderPath("Desktop")
$myDatestamp = get-date -f yyyy-MM-dd


# Contractors OU
$mySearchBase = "OU=Contractors,OU=Users,OU=Corporate,DC=example,DC=local"
$myUsers = Get-ADUser -Filter $myFilter -SearchBase $mySearchBase -Properties $myProperties
# Employees (in house) OU
$mySearchBase = "OU=Employees (in house),OU=Users,OU=Corporate,DC=example,DC=local"
$myUsers += Get-ADUser -Filter $myFilter -SearchBase $mySearchBase -Properties $myProperties
# Employees (IT) OU
$mySearchBase = "OU=Employees (IT),OU=Users,OU=Corporate,DC=example,DC=local"
$myUsers += Get-ADUser -Filter $myFilter -SearchBase $mySearchBase -Properties $myProperties
# Employees (remote) OU
$mySearchBase = "OU=Employees (remote),OU=Users,OU=Corporate,DC=example,DC=local"
$myUsers += Get-ADUser -Filter $myFilter -SearchBase $mySearchBase -Properties $myProperties

# Export Result to CSV File
$myUsers | sort "SamAccountName" | Select $myProperties | Export-Csv $myDesktop\ADQuery_$myDatestamp.csv -noType
