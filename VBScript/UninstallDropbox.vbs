' Search computer for Dropbox installation and uninstall Dropbox if found.
' Created by Andrew Zbikowski <andyzib@gmail.com> 
' Version: 2013-06-10_01
' Tested against Dropbox version 2.0.23 
Option Explicit

' Objects
Dim objShell, objWMI, objFile
' Collections
Dim colFiles
' Strings
Dim strFileQuery, strComputer, strUninstallCmd


Set objShell = WScript.CreateObject("WScript.Shell") 

strComputer = "."
Set objWMI = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" _
		& strComputer & "\root\cimv2")


strFileQuery = "SELECT Name FROM CIM_DataFile WHERE filename = 'DropboxUninstaller' AND extension = 'exe'"

Set colFiles = objWMI.ExecQuery(strFileQuery)

if colFiles.Count > 0 Then
	For Each objFile in colFiles
		On Error Resume Next
		strUninstallCmd = Chr(34) & objFile.Name & Chr(34) & " /S"
		objShell.Run strUninstallCmd,0,True ' Run uninstaller, wait for it to finish. 
	Next
End If

WScript.Quit