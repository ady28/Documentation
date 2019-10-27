#Set up the central file server
Install-WindowsFeature BranchCache –IncludeManagementTools
Install-WindowsFeature FS-BranchCache –IncludeManagementTools

####Configure a distributed cache infrastructure
#Create folder and share for the distributed cache part on the central server
mkdir C:\CacheData1
New-SmbShare -CachingMode BranchCache -Name 'CacheData1' -Path C:\CacheData1
#Info: A GPO can also be created for the server to tell it to use BC for all shares on it
#Configure a GPO for the clients to enable BC and set them as Distributed clients (also set network round trip to 0)
#Configure a GPO for the clients to allow BC content retrieval and peer discovery in the firewall

#To test just use a couple of clients and try to copy the same data on all of them from the server
#Make sure you have a perfmon open with branchcache counters (SMB * are of interest here)

####Configure a distributed cache infrastructure
#Create folder and share for the hosted cache part on the central server
mkdir C:\CacheData2
New-SmbShare -CachingMode BranchCache -Name 'CacheData2' -Path C:\CacheData2
#Copy some files in the folder
#Tell the server to calculate hashes for all files
Publish-BCFileContent -Path C:\CacheData2 -StageData
#Export the cache and data so it can be imported on the branch server
mkdir C:\temp
Export-BCCachePackage -Destination C:\temp -ExportDataCache

#On the hosted cache server
Install-WindowsFeature BranchCache –IncludeManagementTools
#Enable the computer as a hosted cache server
Enable-BCHostedServer -RegisterSCP
#Copy the zip file from the content server
#Import the file
Import-BCCachePackage C:\PeerDistPackage.zip

#Make sure the clients are either configured in distributed cache mode with hosted server autodiscover or in hosted mode

####General commands
#See most info about BC in one command
Get-BCStatus
#Get configuration of BC client
Get-BCClientConfiguration
#See if current computer is a content server (applies also for distributed clients)
Get-BCContentServerConfiguration
#Get info about the cached data
Get-BCDataCache
#Get info about cached hashes
Get-BCHashCache
#See if a computer is a hosted cache server (clients do not apply)
Get-BCHostedCacheServerConfiguration
#Check if all networking components are in the correct status
Get-BCNetworkConfiguration