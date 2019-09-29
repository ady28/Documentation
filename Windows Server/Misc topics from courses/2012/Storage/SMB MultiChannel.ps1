#Multichannel is enabled by default

#Get the status
Get-SmbServerConfiguration | Select-Object EnableMultiChannel | Format-List
#Disable SMB multichannel
Set-SmbServerConfiguration -EnableMultiChannel $false -Confirm:$false
#Enable it again
Set-SmbServerConfiguration -EnableMultiChannel $true -Confirm:$false

#Get data about a SMB connection (run on smb client)
Get-SmbConnection
Get-SmbMultichannelConnection

#Get data about network adapters with regard to smb multichannel
Get-SmbServerNetworkInterface
Get-SmbClientNetworkInterface