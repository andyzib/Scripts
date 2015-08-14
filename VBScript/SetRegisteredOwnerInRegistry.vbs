' Updates owner field in registry with the current user's display name. 
' This helps when viewing the computer in SpiceWorks. 
' Requires giving users access to write to this key, which can be done
' via group policy. 

On Error Resume Next

Set oADSystemInfo = CreateObject("ADSystemInfo")

Set objShell = WScript.CreateObject("WScript.Shell")

' get user object
Set oADsUser = GetObject("LDAP://" & oADSystemInfo.UserName)

'Write the user's display name to the registry
objShell.RegWrite  "HKLM\Software\Microsoft\Windows NT\CurrentVersion\RegisteredOwner", oADsUser.DisplayName

'comment out the line above and uncomment this line if you wish to only write
' the username to the registry.
'objShell.RegWrite  "HKLM\Software\Microsoft\Windows NT\CurrentVersion\RegisteredOwner", oADSystemInfo.UserName

