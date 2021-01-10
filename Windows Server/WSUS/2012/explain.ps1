#Tested on WS 2012
#Installed all updates from WU

#Add the WSUS role and install the required roles/features
Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

#Configure WSUS post install
#Create a directory for WSUS
New-Item 'C:\WSUS' -ItemType Directory
& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall CONTENT_DIR=C:\WSUS

#Change different WSUS config items
$wsus = Get-WSUSServer
$wsusConfig = $wsus.GetConfiguration()
Set-WsusServerSynchronization –SyncFromMU
$wsusConfig.UseProxy=$true
$wsusConfig.ProxyName='192.168.1.254'
$wsusConfig.Save()
$wsusConfig.AllUpdateLanguagesEnabled = $false
$wsusConfig.SetEnabledUpdateLanguages(“en”)
$wsusConfig.Save()
$wsusConfig.TargetingMode='Client'
$wsusConfig.Save()
#Get WSUS Subscription and perform initial synchronization to get latest categories
$subscription = $wsus.GetSubscription()
$subscription.StartSynchronizationForCategoryOnly()
# $subscription.GetSynchronizationStatus() should not be Running to be done

#Get only 2012 updates
Get-WsusProduct | Where-Object {$_.Product.Title -ne "Windows Server 2012"} | Set-WsusProduct -Disable
#Get only specific classifications
Get-WsusClassification | Where-Object { $_.Classification.Title -notin 'Update Rollups','Security Updates','Critical Updates','Updates','Service Packs'  } | Set-WsusClassification -Disable
Get-WsusClassification | Where-Object { $_.Classification.Title -in 'Update Rollups','Security Updates','Critical Updates','Updates','Service Packs'  } | Set-WsusClassification

#Start a sync
$subscription.StartSynchronization()
$subscription.GetSynchronizationProgress()
$subscription.GetSynchronizationStatus()

#Other things that can be done are configure auto approval rules and sync times

#Create wsus target groups
#Create a GPO and set enable automatic updates, target groups and intranet wsus server
