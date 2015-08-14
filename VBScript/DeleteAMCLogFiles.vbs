' Because salesforce.com and AMC Technologies are outrageously stupid, this script looks
' for the logfiles the salesforce.com CTI adapter creates and deletes them. 
' Log files are located in: 
' "BrowserConnectorLogFile"="C:\\Program Files (x86)\\AMC Technology\\Application Adapters\\Salesforce.com Adapter\\browser_connector.log"
' "CtiConnectorLogFile"="C:\\Program Files (x86)\\AMC Technology\\Application Adapters\\Salesforce.com Adapter\\cti_connector.log"
Option Explicit
On Error Resume Next

' Directory where the logfiles are located. 
Const LOGDIR = "C:\Program Files (x86)\AMC Technology\Application Adapters\Salesforce.com Adapter\Logs\" 
Const DELETEREADONLY = True
Dim objFSO

Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FolderExists(LOGDIR) Then
	objFSO.DeleteFile(LOGDIR & "*.*"), DELETEREADONLY
End If

WScript.Quit