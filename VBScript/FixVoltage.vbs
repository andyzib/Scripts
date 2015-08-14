On Error Resume Next

' Close Outlook
Set Outlook = GetObject(, "Outlook.Application")
If Err = 0 Then
	Outlook.Quit()
	Set Outlook = Nothing
End If

WScript.Echo "If Outlook is not closed, please close it now and then click OK." 

' Fixing Voltage
Set objShell = WScript.CreateObject("WScript.Shell")
' Voltage 64-bit Product Code: {5E95C102-F982-4F90-B890-D48729D175A6}
' msiexec.exe /f Options: 
' p: Reinstalls only if file is missing.
' o: Reinstalls if file is missing or if an older version is installed.
' e: Reinstalls if file is missing or an equal or older version is installed.
' d: Reinstalls if file is missing or a different version is installed.
' c: Reinstalls if file is missing or the stored checksum does not match the calculated value.
' a: Forces all files to be reinstalled.
' u: Rewrite all required user-specific registry entries.
' m: Rewrites all required computer-specific registry entries.
' s: Overwrites all existing shortcuts.
' v: Runs from source and re-caches the local package.
objShell.Run "%windir%\system32\msiexec.exe /fu {F8472E7F-DC87-403D-A9CB-F0CE2BB348BD}", 1, True

' Launch Outlook
objShell.Run "outlook.exe", 1, False

Wscript.Quit