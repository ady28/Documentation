#Build a nice file name
$date = get-date -Format M_d_yyyy_hh_mm_ss
$csvfile = ".\AllAttentionRequiringVMs_"+$date+".csv"
#Build the header row for the CSV file
$csv = "VM Name, Date, Server, Message `r`n"
#Find all VMs that require your attention
$VMList = get-vm | where {$_.ReplicationHealth -eq "Critical" -or $_.ReplicationHealth -eq "Warning"}
#Loop through each VM to get the corresponding events
ForEach ($VM in $VMList)
{
    $VMReplStats = $VM | Measure-VMReplication
    #We should start getting events after last successful replication. Till then replication was happening.
    $FromDate = $VMReplStats.LastReplicationTime 
    #This string will filter for events for the current VM only
    $FilterString = "<QueryList><Query Id='0' Path='Microsoft-Windows-Hyper-V-VMMS-Admin'><Select Path='Microsoft-Windows-Hyper-V-VMMS-Admin'>*[UserData[VmlEventLog[(VmId='" + $VM.ID + "')]]]</Select></Query></QueryList>" 
    $EventList = Get-WinEvent -FilterXML $FilterString  | Where {$_.TimeCreated -ge $FromDate -and $_.LevelDisplayName -eq "Error"} | Select -Last 3
    #Dump relevant information to the CSV file
    foreach ($Event in $EventList)
    {
        If ($VM.ReplicationMode -eq "Primary") 
        {
            $Server = $VMReplStats.PrimaryServerName
        }
        Else
        {
            $Server = $VMReplStats.ReplicaServerName
        }
        $csv +=$VM.Name + "," + $Event.TimeCreated + "," + $Server + "," + $Event.Message +"`r`n"
    }
} 
#Create a file and dump all information in CSV format
$fso = new-object -comobject scripting.filesystemobject
$file = $fso.CreateTextFile($csvfile,$true)
$file.write($csv)
$file.close()