#When installing Failover cluster manager with the RSAT tools you also get the CAU tools
#Assume that a failover cluster already exists and is ready to be tested with CAU

###Using CAU with a separate coordinator
##Run on the coordinator node
Install-WindowsFeature RSAT-Clustering
Get-Command -Module ClusterAwareUpdating

##Run on the cluster nodes
#Enable automatic restarts
Set-NetFirewallRule -Group "@firewallapi.dll,-36751" -Profile Domain -Enabled true

##Run on the coordinator
#Check if cluster is ready for CAU; some bullet points are ok to fail if not using
#Updates from the internet or self updating mode
Test-CauSetup -ClusterName FS02

#Make sure that a GPO is configure to point the cluster nodes to a WSUS server
#Scan for applicable updates
Invoke-CauScan -ClusterName FS02
#Start an update session with default values
#Get info about the updte process
Get-CauRun