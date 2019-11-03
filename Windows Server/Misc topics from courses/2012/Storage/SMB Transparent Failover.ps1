#Test a cluster with 2 FS roles. One for General purpose high available SMB share and NFS share
#And one with a Scale out file server share

#Create 2 VMs with 3 shared disks (1 quorum and 2 data) - i will use another WS 2012 as a iSCSI server

###Commands to run on the server hosting the iSCSI target
Install-WindowsFeature FS-iSCSITarget-Server
New-IscsiServerTarget -TargetName StorageForFS02
New-IscsiVirtualDisk -Path i:\iSCSI\Quorum.VHD -Size 1GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'StorageForFS02' -Path i:\iSCSI\Quorum.VHD
New-IscsiVirtualDisk -Path i:\iSCSI\Data1.VHD -Size 2.5GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'StorageForFS02' -Path i:\iSCSI\Data1.VHD
New-IscsiVirtualDisk -Path i:\iSCSI\Data2.VHD -Size 3GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'StorageForFS02' -Path i:\iSCSI\Data2.VHD
#Permit the 2 servers to mount the LUNs from the target by their iscsi initiator addresses
set-IscsiServerTarget -TargetName 'StorageForFS02' -InitiatorIds 'IQN:iqn.1991-05.com.microsoft:fs02a.testcorp.com','IQN:iqn.1991-05.com.microsoft:fs02b.testcorp.com'
#Values that we can use for iniator ids are: DNSName, IPAddress, IPv6Address, IQN and MACAddress (DNSName:...)

###Commands to be run on both cluster nodes
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule
#use one of these commands to get the iscsi initiator address for the servers
iscsicli.exe
Get-InitiatorPort | select -ExpandProperty NodeAddress
#Start to connect the storage
New-IscsiTargetPortal -TargetPortalAddress fs01
Get-IscsiTarget | Connect-IscsiTarget
#see if the disks have been mounted
Get-Disk

###Start installing and configuring cluster
#Run on both nodes to install feature
Install-WindowsFeature Failover-Clustering -IncludeManagementTools
#See all CmdLets
Get-Command -Module FailoverClusters

#Run the commands directly on one of the cluster nodes (not through ps remoting)
Test-Cluster -Node FS02A,FS02B
New-Cluster -Name FS02 -Node FS02A,FS02B -StaticAddress 192.168.1.13

#Run the commands on one of the cluster nodes
#Format the quorum disk
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter E -FileSystem NTFS
#add it to the cluster
Get-Disk -Number 1 | Add-ClusterDisk
Set-ClusterQuorum -NodeAndDiskMajority 'Cluster Disk 1'
#Initialize the other 2 disks
Initialize-Disk -Number 2 -PartitionStyle GPT
Initialize-Disk -Number 3 -PartitionStyle GPT
New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
New-Partition -DiskNumber 3 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter F -FileSystem NTFS -Force -Confirm:$false
Format-Volume -DriveLetter G -FileSystem NTFS -Force -Confirm:$false
Get-Disk -Number 2 | Add-ClusterDisk
Get-Disk -Number 3 | Add-ClusterDisk

#Install the fs role on both nodes
Add-WindowsFeature File-Services

###General file server
#Run directly on a cluster node (no remoting) to create a clustered general purpose file server
Add-ClusterFileServerRole -StaticAddress 192.168.1.14 -Name 'FS02G' -Storage 'Cluster Disk 2'

#Create a highly available general purpose share
New-Item F:\TestShare -ItemType Directory
New-SmbShare -Name 'TestShare$' -Path G:\TestShare -ScopeName FS02G

###SOFS
#Add the disk 3 of the cluster to a CSV
Add-ClusterSharedVolume -Name 'Cluster Disk 3'
#Run this command directly on a cluster node with no remoting
Add-ClusterScaleOutFileServerRole -Name FS02SOFS
#Create a folder for the new share in the csv
New-Item C:\ClusterStorage\Volume2\TestSOFSShare -ItemType Directory
#create the share
New-SmbShare -Path C:\ClusterStorage\Volume2\TestSOFSShare -Name 'TestSOFSShare$' -ScopeName FS02SOFS
