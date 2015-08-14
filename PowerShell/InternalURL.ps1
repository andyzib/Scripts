#InternalURL.ps1
$urlpath = Read-Host "Type internal Client Access FQDN starting with http:// or https://"
Set-AutodiscoverVirtualDirectory -Identity * internalurl “$urlpath/autodiscover/autodiscover.xml”
Set-ClientAccessServer Identity * AutodiscoverServiceInternalUri “$urlpath/autodiscover/autodiscover.xml”
Set-webservicesvirtualdirectory Identity * internalurl “$urlpath/ews/exchange.asmx”
Set-oabvirtualdirectory Identity * internalurl “$urlpath/oab”
Set-owavirtualdirectory Identity * internalurl “$urlpath/owa”
Set-ecpvirtualdirectory Identity * internalurl “$urlpath/ecp”
Set-ActiveSyncVirtualDirectory -Identity * -InternalUrl "$urlpath/Microsoft-Server-ActiveSync"
#get commands to  to doublecheck the config
get-AutodiscoverVirtualDirectory | ft identity,internalurl
get-ClientAccessServer | ft identity,AutodiscoverServiceInternalUri
get-webservicesvirtualdirectory | ft identity,internalurl
get-oabvirtualdirectory | ft identity,internalurl
get-owavirtualdirectory | ft identity,internalurl
get-ecpvirtualdirectory | ft identity,internalurl
get-ActiveSyncVirtualDirectory | ft identity,internalurl