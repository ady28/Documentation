#Get the device that implements the GenerationID
Get-WmiObject win32_pnpentity | where {$_.caption -eq 'Microsoft Hyper-V Generation Counter'}

#Get the current value of this ID from AD
Get-ADObject -Filter {samaccountname -like "DC01*"} -Properties * | Select-Object -ExpandProperty msDS-GenerationId

#Testing a revert to a previous snapshot
#Create a user and make sure it is replicated on both DCs
#Create a checkpoint of DC02 and then wait some minutes
#Delete the user and then apply the checkpoint; restart after that

#Testing cloning a domain controller
#Create a new DC with only ADDS and DNS on it
#Add the new DC to the group for clonable DCs
Add-ADGroupMember 'Cloneable Domain Controllers' -Members 'CN=DC03,OU=Domain Controllers,DC=testcorp,DC=com'
#Make sure that you do not have anything that does not support DC cloning
Get-ADDCCloningExcludedApplicationList
#In case you get anything then it means that item is not supported for cloning
#You can generate an exclusion list
Get-ADDCCloningExcludedApplicationList -GenerateXml
#Generate a config file for cloning
New-ADDCCloneConfigFile -Static -IPv4Address 192.168.1.16 -IPv4DefaultGateway 192.168.1.254 -IPv4DNSResolver 192.168.1.1 -IPv4SubnetMask 255.255.255.0 -CloneComputerName DC04
#Now we stop the DC03 VM and export it
#Import VM and generate new ID
#Start the 2 domain controllers; after 2-3 minutes DC04 should appear as a DC in AD

Remove-ADGroupMember -Identity 'Cloneable Domain Controllers' -Members 'CN=DC03,OU=Domain Controllers,DC=testcorp,DC=com' -Confirm:$false