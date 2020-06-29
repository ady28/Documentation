#Host NIC teaming in VMM
$1 = New-SCLogicalNetwork -Name 'Team'
$2 = New-SCLogicalNetworkDefinition -Name 'Team_0' -LogicalNetwork $1 -VMHostGroup (Get-SCVMHostGroup -Name 'All Hosts') -SubnetVLAN (New-SCSubnetVLAN -VLANId 0)
$3 = New-SCNativeUplinkPortProfile -Name 'Team' -LogicalNetworkDefinition $2 -LBFOLoadBalancingAlgorithm 'HostDefault' -LBFOTeamMode 'SwitchIndependent'
$4 = New-SCLogicalSwitch -Name 'Team' -SwitchUplinkMode 'Team'
New-SCUplinkPortProfileSet -Name 'Team' -LogicalSwitch $4 -NativeUplinkPortProfile $3

#Guest NIC teaming in VMM
New-SCVirtualNetworkAdapterNativePortProfile -AllowTeaming $true

#VMQ 
Get-NetAdapterVmq
Enable-NetAdapterVmq
Disable-NetAdapterVmq
#RSS
Get-NetAdapterRss
Enable-NetAdapterRss
Disable-NetAdapterRss

#Jumbo frames
Set-NetadapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue 9014

#SR-IOV
New-VMSwitch -EnableIov
