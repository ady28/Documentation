#Install dedup
Install-WindowsFeature FS-Data-Deduplication

#Enable deduplication
Enable-DedupVolume G:

#Deduplicate files no matter how old they are
Set-DedupVolume -Volume G: -MinimumFileAgeDays 0

#Start a dedup job
Start-DedupJob -Type Optimization -Volume G:

#Get status of deduplication
Get-DedupStatus

#Evaluate saving for a volume
ddpeval F: