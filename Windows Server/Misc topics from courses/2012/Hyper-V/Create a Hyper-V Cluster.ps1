#Prepare the LUNs
New-IscsiServerTarget -TargetName 'HV02Storage'
New-IscsiVirtualDisk -Path E:\iSCSI\HV02Q.VHD -Size 1GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'HV02Storage' -Path E:\iSCSI\HV02Q.VHD
New-IscsiVirtualDisk -Path E:\iSCSI\HV02D.VHD -Size 3GB
Add-IscsiVirtualDiskTargetMapping -TargetName 'HV02Storage' -Path E:\iSCSI\HV02D.VHD
Set-IscsiServerTarget -TargetName 'HV02Storage' -InitiatorIds 'IQN:iqn.1991-05.com.microsoft:hv02a.testcorp.com','IQN:iqn.1991-05.com.microsoft:hv02b.testcorp.com'

#Connect to the LUNs from both hosts
Set-Service -Name MSiSCSI -StartupType Automatic
Start-Service MSiSCSI
Get-NetFirewallServiceFilter -Service msiscsi | Get-NetFirewallRule | Enable-NetFirewallRule
New-IscsiTargetPortal -TargetPortalAddress bcm01
Get-IscsiTarget | Connect-IscsiTarget
Get-IscsiSession | Register-IscsiSession

#Install Hyper-V and Failover Clustering on both nodes
Enable-WindowsOptionalFeature –Online -FeatureName Microsoft-Hyper-V –All -NoRestart
Install-WindowsFeature Failover-Clustering -IncludeManagementTools
Install-WindowsFeature Hyper-V-PowerShell
Restart-Computer -Force

#Create a switch on both Hyper-V nodes
New-VMSwitch -Name 'TestSW' -SwitchType Private

#Run the commands directly on one of the nodes
Test-Cluster -Node HV02A,HV02B
New-Cluster -Name HV02 -Node HV02A,HV02B -StaticAddress 192.168.10.18
Get-ClusterResource -Name 'Cluster Name' | Set-ClusterParameter -Name PublishPTRRecords -Value 1
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter E -FileSystem NTFS -Confirm:$false
Get-Disk -Number 1 | Add-ClusterDisk
Set-ClusterQuorum -NodeAndDiskMajority 'Cluster Disk 1'
Initialize-Disk -Number 2 -PartitionStyle GPT
New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
Format-Volume -DriveLetter F -FileSystem NTFS -Force -Confirm:$false
Get-Disk -Number 2 | Add-ClusterDisk
Add-ClusterSharedVolume -Name 'Cluster Disk 2'
####

#Run on both nodes
Set-VMHost -VirtualHardDiskPath 'C:\ClusterStorage\Volume1\VMs' -VirtualMachinePath 'C:\ClusterStorage\Volume1\VMs'
###

#Run on one of the hosts
New-VM -BootDevice CD -MemoryStartupBytes 512MB -Name 'TestVM' -NewVHDSizeBytes 300MB -NewVHDPath 'C:\ClusterStorage\Volume1\VMs\Virtual Machines\TestVM.vhdx'
Add-ClusterVirtualMachineRole -VMName TestVM







