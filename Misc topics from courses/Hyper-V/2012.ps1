#All commands tested on Hyper-V in Windows Server 2012

#Set some general hyper-v settings
Set-VMHost -VirtualMachineMigrationAuthenticationType Kerberos -VirtualHardDiskPath 'C:\VMs' -VirtualMachinePath 'C:\VMs' -UseAnyNetworkForMigration $true
#Enable vm live migrations
Enable-VMMigration
#Add a subnet in the list of migration networks. Has effect if -UseAnyNetworkForMigration is $false
Add-VMMigrationNetwork -Subnet '192.168.1.0/24'
#Configure Hyper-V replica
Set-VMReplicationServer -ReplicationEnabled $true -AllowedAuthenticationType Kerberos -DefaultStorageLocation 'C:\Replicas' -ReplicationAllowedFromAnyServer $true
#Set a server for trusted replication. Works only if -ReplicationAllowedFromAnyServer is $false
New-VMReplicationAuthorizationEntry -AllowedPrimaryServer 'HV02.testcorp.com' -ReplicaStorageLocation 'C:\ReplicaHV02' -TrustGroup 'ReplicaGroup'
Remove-VMReplicationAuthorizationEntry -AllowedPrimaryServer 'HV02.testcorp.com'
#Enable the firewall rule for replication on port 80
Enable-NetFirewallRule VIRT-HVRHTTPL-In-TCP-NoScope

#Create a new private switch
New-VMSwitch -Name 'TestSW' -SwitchType Private

#Creating VMs and VHD files
#Create a simple VM that boots from the CD and has a 800MB startup RAM value
New-VM -BootDevice CD -MemoryStartupBytes 800MB -Name 'TestVM'
#Create the VM and assign it a switch
New-VM -BootDevice CD -MemoryStartupBytes 512MB -Name 'TestVM' -SwitchName 'TestSW'
#Create the VM also with a VHDX that is dynamically expanding to max 300MB
New-VM -BootDevice CD -MemoryStartupBytes 512MB -Name 'TestVM' -NewVHDSizeBytes 300MB -NewVHDPath 'C:\VMs\Virtual Machines\TestVM.vhdx'
#Create the VM and give it an existing VHDX file
New-VM -BootDevice CD -MemoryStartupBytes 512MB -Name 'TestVM' -VHDPath 'C:\VMs\Virtual Machines\TestVM.vhdx'

#Set some VM parameters
Set-VM -ProcessorCount 2 -DynamicMemory -Name 'TestVM' -MemoryMinimumBytes 400MB -MemoryMaximumBytes 512MB -AutomaticStartAction Nothing -AutomaticStopAction ShutDown -AutomaticStartDelay 60 -Notes 'Just a test VM'
#Change a VM's startup order
$NewOrder='IDE','CD','Floppy','LegacyNetworkAdapter'
Set-VMBios -VMName 'TestVM' -StartupOrder $NewOrder
#Set advanced memory settings like weight and priority (startupbytes and so on can be also modified)
Set-VMMemory -Buffer 10 -Priority 30 -VMName 'TestVM'
#Configure VM integration service checkboxes
Get-VMIntegrationService -VMName TestVM
Disable-VMIntegrationService -Name 'Time Synchronization' -VMName 'TestVM'

#VM export and import
#Export VM to a path that will be created at export time
Export-VM -Path 'C:\Export' -Name 'TestVM'
#Import VM and keep the files exactly where they are
Import-VM -Path 'C:\Import\TestVM\Virtual Machines\BEFE2C60-E49F-429C-95D1-DB7D884B3BEA.XML'
#Import VM and copy the files to the default locations (VHDs may be put directly in the configured location)
Import-VM -Path 'C:\Import\TestVM\Virtual Machines\BEFE2C60-E49F-429C-95D1-DB7D884B3BEA.XML' -Copy
#Import VM and copy the files to the default locations (specify a location for the disk files)
Import-VM -Path 'C:\Import\TestVM\Virtual Machines\BEFE2C60-E49F-429C-95D1-DB7D884B3BEA.XML' -Copy -VhdDestinationPath 'C:\VMs\Virtual Machines'


#VM snapshots
Checkpoint-VM -Name 'TestVM' -SnapshotName 'First snap'
Get-VMSnapshot -VMName 'TestVM'
Restore-VMSnapshot -VMName 'TestVM' -Name 'First snap' -Confirm:$false
Remove-VMSnapshot -VMName 'TestVM' -Name 'Snap 2'

#Work with disks
#Create a new VHDX that is fixed
New-VHD -LogicalSectorSizeBytes 4096 -Path 'C:\VMs\Virtual Machines\TestVM_D.VHDX' -SizeBytes 120MB -Fixed
Add-VMHardDiskDrive -ControllerType SCSI -Path 'C:\VMs\Virtual Machines\TestVM_D.VHDX' -VMName 'TestVM'
Get-VMHardDiskDrive -VMName 'TestVM'
Remove-VMHardDiskDrive -VMName 'TestVM' -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0

#Live migrate a VM to another host with all its VHD files and delete it from the source while keeping the destination default storage locations (shared nothing lm)
Move-VM -Name 'TestVM' -DestinationHost 'HV01.testcorp.com' -IncludeStorage

#Enable replication for a VM with 3 stored replicas and no VSS
Enable-VMReplication -VMName 'TestVM' -ReplicaServerName 'HVS01.testcorp.com' -CompressionEnabled $true -RecoveryHistory 3 -ReplicaServerPort 80 -AuthenticationType Kerberos
#Start the initial replication imediately
Start-VMInitialReplication -VMName 'TestVM'
Get-VMReplication -VMName 'TestVM'
Measure-VMReplication -VMName 'TestVM'
Suspend-VMReplication -VMName 'TestVM'
Resume-VMReplication -VMName 'TestVM'
#Failover a VM to the replica server and convert the replica VM to a primary one and reverse the replication
Start-VMFailover -VMName 'TestVM' -Prepare -Confirm:$false #Run on primary host
Start-VMFailover -VMName 'TestVM' -Confirm:$false #Run on replica host
Set-VMReplication -Reverse -VMName 'TestVM' #Run on replica host
#The VM that is now the replica will not be moved to the replica path but remain where it is

#Delete a VM; does not delete any HDDs that the VM uses
Remove-VM -Name 'TestVM' -Confirm:$false -Force
