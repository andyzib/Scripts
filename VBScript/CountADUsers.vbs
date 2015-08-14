Set objConnection = CreateObject("ADODB.Connection") 
Set objCommand = CreateObject("ADODB.Command") 
objConnection.Provider = "ADsDSOOBject" 
objConnection.Open "Active Directory Provider" 
Set objCommand.ActiveConnection = objConnection 
 
Set objRootDSE = GetObject("LDAP://RootDSE") 
strDNSDomain = objRootDSE.Get("defaultNamingContext") 
strFilter = "(&(sAMAccountType=805306368)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))" 

strDomain = inputbox( "Please enter a domain name", "Input" )

strQuery = "<LDAP://" & strDomain & ">;" & strFilter & ";distinguishedName;subtree" 
 
objCommand.CommandText = strQuery 
objCommand.Properties("Page Size") = 10000 
objCommand.Properties("Timeout") = 30 
objCommand.Properties("Cache Results") = False 
  
Set rs = objCommand.Execute
MsgBox "Count of enabled users: " & rs.RecordCount 'users