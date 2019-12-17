#To enable the use of dynamic access control in a domain add the following to the default DC policy
#Computer Configuration,Policies,Administrative Templates,System,KDC
#Enable KDC support for claims, compound authentication, and Kerberos armoring

#Install FSRM on the file server that will host the files
Install-WindowsFeature FS-Resource-Manager
#Install the Microsoft Office Filter Pack 2010 on the file server to be able to analyze and clasify files
FilterPack64bit.exe /quiet /norestart
#Install and configure AD RMS on the file server
Add-WindowsFeature ADRMS -IncludeAllSubFeature -IncludeManagementTools 