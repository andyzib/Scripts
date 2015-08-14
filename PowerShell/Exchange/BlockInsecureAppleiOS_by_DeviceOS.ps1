#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin 
# For Exchange 2010
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Add-PSSnapin Microsoft.Exchange.Management.Powershell.Support
New-ActiveSyncDeviceAccessRule -QueryString "6.0 10A403" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.0 10A405" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.0 10A406" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.0.1 10A523" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.0.1 10A525" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.0.2 10A551" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1 10B141" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1 10B142" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1 10B143" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1 10B144" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1.1 10B145" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1.2 10B146" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1.2 10B147" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1.3 10B329" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1.4 10b350" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "6.1.5 10B500" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0 11A465" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0 11A466" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0.1 11A470a" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0.2 11A501" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0.3 11B511" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0.4 11B554a" -Characteristic DeviceOS -AccessLevel Block
New-ActiveSyncDeviceAccessRule -QueryString "7.0.5 11B601" -Characteristic DeviceOS -AccessLevel Block