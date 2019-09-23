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

#Live migrate a VM to another host with all its VHD files and delete it from the source while keeping the destination default storage locations (shared nothing lm)
Move-VM -Name 'TestVM' -DestinationHost 'HV01.testcorp.com' -IncludeStorage

#Delete a VM; does not delete any HDDs that the VM uses
Remove-VM -Name 'TestVM' -Confirm:$false -Force
