#Test the cluster before install - run locally on one of the nodes
Test-Cluster –Node 'S2DCL01A','S2DCL01B' –Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

#Create cluster
New-Cluster –Name 'S2DCL01' –Node 'S2DCL01A','S2DCL01B' –NoStorage

#Enable storage spaces direct
Enable-ClusterStorageSpacesDirect

#create a volume
New-Volume -FriendlyName "Volume1" -FileSystem CSVFS_ReFS -StoragePoolFriendlyName S2D* -Size 2GB

#Not part of s2d - create sofs
Add-ClusterScaleOutFileServerRole -Name SOFS -Cluster FSCLUSTER