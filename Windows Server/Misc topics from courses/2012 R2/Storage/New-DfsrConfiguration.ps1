##########################################################
#
#    Copyright (c) Microsoft. All rights reserved.
#    This code is licensed under the Microsoft Public License.
#    THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
#    ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
#    IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
#    PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
#
##########################################################

<#
    .SYNOPSIS
        Creates a new DFSR replication group and one replicated folder on the specified file
        servers with the connection topology between them.
    .DESCRIPTION
        Creates a new replication group and a new replicated folder, adds member computers and the
        desired connection topology, and then configures memberships.  The local computer (where
        this script is run) must be running either Windows Server 2012 R2 with the DFSR role
        installed ('Install-WindowsFeature RSAT-DFS-Mgmt-Con'), or Windows 8.1 with RSAT installed
        from the Microsoft Download Center.  All member computers must be running Windows Server
        2012 R2 or later with the DFSR role installed.  All DFSR objects will be created in the
        current user's domain.
    .EXAMPLE
        .\New-DfsrConfiguration.ps1 -GroupName RG01 -FolderName RF01 -ComputerName SRV01,SRV02,SRV03 -PrimaryComputerName SRV01 -ContentPath C:\RF01 -Verbose

        - Creates a new replication group named "RG01" and a replicated folder named "RF01".
        - Adds the member computers named SRV01, SRV02, and SRV03 to "RG01".
        - Adds all six bidirectional pairwise connections between all three members (a full-mesh
          connection topology).
        - Configures all memberships to use C:\RF01 as the folder for the root of each member's
          local copy of "RF01".
        - Sets SRV01 to be the primary member computer.
    .EXAMPLE
        .\New-DfsrConfiguration.ps1 -GroupName RG02 -FolderName RF02 -HubComputerName SRV01 -ComputerName SRV02,SRV03 -PrimaryComputerName SRV03 -ContentPath C:\RF02 -Verbose

        - Creates a new replication group named "RG02" and a replicated folder named "RF02".
        - Adds the member computers named SRV01, SRV02, and SRV03 to "RG02".
        - Adds four connections: bidirectionally between SRV01 and each of SRV02 and SRV03.
        - Configures all memberships to use C:\RF02 as the folder for the root of each member's
          local copy of "RF02".
        - Sets SRV03 to be the primary member computer.
    .EXAMPLE
        .\New-DfsrConfiguration.ps1 -GroupName RG03 -FolderName RF03 -ComputerName SRV02,SRV03 -PrimaryComputerName SRV01 -ContentPath C:\RF03 -StagingPathQuotaInMB (1024 * 32) -Verbose

        - Creates a new replication group named "RG03" and a replicated folder named "RF03".
        - Adds the member computers named SRV01, SRV02, and SRV03 to "RG03".
        - Adds all six bidirectional pairwise connections between all three members (a full-mesh
          connection topology).
        - Configures all memberships to use C:\RF03 as the folder for the root of each member's
          local copy of "RF03".
        - Sets SRV01 to be the primary member computer and the staging quota to 32 GB.
    .PARAMETER GroupName
        The name of the replication group to create.
    .PARAMETER FolderName
        The name of the replicated folder to create.
    .PARAMETER HubComputerName
        The name of the member computer to serve as the hub for a hub-and-spoke connection
        topology.  Do not specify this parameter (or use $null) for a full-mesh connection
        topology.
    .PARAMETER ComputerName
        A list of computer names to add as members of the replication group.
    .PARAMETER PrimaryComputerName
        The name of the member computer to serve as the authoritative copy during initial
        replication.
    .PARAMETER ContentPath
        The path that member computers will use for their local copy of the new replicated folder.
    .PARAMETER StagingPathQuotaInMB
        The maximum size in megabytes that the staging folder grows before purging oldest files.
#>

param (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a unique replication group name.')]
    [ValidateNotNullOrEmpty()]
    [string]$GroupName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a replicated folder name.')]
    [ValidateNotNullOrEmpty()]
    [string]$FolderName,

    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a member computer name to act as the hub server.')]
    [ValidateNotNullOrEmpty()]
    [string]$HubComputerName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a list of member computer names.')]
    [ValidateNotNullOrEmpty()]
    [string[]]$ComputerName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a member computer name to act as the primary member during initial replication.')]
    [ValidateNotNullOrEmpty()]
    [string]$PrimaryComputerName,

    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a content folder path.')]
    [ValidateNotNullOrEmpty()]
    [string]$ContentPath,

    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true,
        HelpMessage='Please specify a maximum size in megabytes for the staging folder.')]
    [ValidateRange(10,[UInt32]::MaxValue)]
    [UInt32]$StagingPathQuotaInMB
)

# Save error preference (in case of dot sourcing) then stop this script on the first error.
$prevErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"

# Save progress preference (in case of dot sourcing) then suppress progress messages from the
# Test-DfsrInstalled workflow below because they are not helpful.
$prevProgressPreference = $ProgressPreference
$ProgressPreference = "SilentlyContinue"

Try {
    if ($HubComputerName) {
        $allComputerNames = $ComputerName + $HubComputerName
    } else {
        $allComputerNames = $ComputerName
    }

    if (!$allComputerNames.Contains($PrimaryComputerName)) {
        $allComputerNames = $allComputerNames + $PrimaryComputerName
    }
    # $allComputerNames now contains all DFSR member computers.

    $spokeComputerNames = $ComputerName
    if (!$spokeComputerNames.Contains($PrimaryComputerName) -and ($PrimaryComputerName -ne $HubComputerName)) {
        $spokeComputerNames = $spokeComputerNames + $PrimaryComputerName
    }
    # $spokeComputerNames now contains all spoke member computers (only used if a hub-and-spoke
    # connection topology is desired).

    # Check that there are at least two member computers specified.
    if ($allComputerNames.Count -lt 2) {
        throw "At least two member computers must be specified for replication."
    }

    # Check that the DFSR PowerShell cmdlets are installed locally.  Note the '*' at the end
    # because otherwise it would return an error (and end the script due to the above changes to
    # $ErrorActionPreference).
    if (!(Get-Command "Get-DfsReplicationGroup*")) {
        throw "Please install the DFSR PowerShell module on the local computer.  For Windows Server 2012 R2 or later, use 'Install-WindowsFeature RSAT-DFS-Mgmt-Con'.  For Windows 8.1 or later, download the RSAT package from the Microsoft Download Center."
    }

    # Verify that the DFSR PowerShell role is installed on each member computer.  A PowerShell
    # workflow allows foreach -parallel which checks each member in parallel.
    workflow Test-DfsrInstalled {
        <#
            .SYNOPSIS
            .PARAMETER MemberComputerNames
                A list of computer names to verify that the DFSR role is installed.
        #>
        param (
            [string[]] $MemberComputerNames
        )

        Write-Verbose "Testing if the DFSR role is installed on all member computers: $MemberComputerNames"
        foreach -parallel ($memberComputer in $MemberComputerNames) {
            $installed = Get-WindowsFeature FS-DFS-Replication -ComputerName $memberComputer
            if ($installed.Installed) {
                Write-Verbose "Verified that the DFSR role is installed on $memberComputer"
            } else {
                throw "Please install the DFSR role on the member computer named $memberComputer using 'Install-WindowsFeature FS-DFS-Replication -ComputerName $memberComputer'."
            }
        }
    }
    Test-DfsrInstalled $allComputerNames


    # Create DFSR configuration Active Directory objects

    # Create a new replication group
    # ------------------------------
    # A replication group's name is unique across the domain.  It serves as the container for all
    # other DFSR configuration objects in AD.
    Write-Verbose "Creating a new replication group named '$GroupName'"
    $rg = New-DfsReplicationGroup -GroupName $GroupName
    Write-Output $rg

    # Create a new replicated folder in the replication group
    # -------------------------------------------------------
    # A replicated folder's name is unique across the replication group.  It serves as the
    # container for the data that will be replicated.
    Write-Verbose "Creating a new replicated folder named '$FolderName'"
    $rf = New-DfsReplicatedFolder -GroupName $GroupName -FolderName $FolderName
    Write-Output $rf

    # Add members to the replication group
    # ------------------------------------
    # A member is a computer that is involved in a particular replication group.  Note that this
    # definition differs from the AD sense; an Active Directory domain controller can be a member
    # of a replication group.
    Write-Verbose "Adding the following member computers to the replication group named '$GroupName': $allComputerNames"
    $members = Add-DfsrMember -GroupName $GroupName -ComputerName $allComputerNames
    Write-Output $members

    # Add connections to the replication group
    # ----------------------------------------
    # A connection allows replication between two members of a replication group.  It is
    # directional, meaning if an enabled connection from SRV01 to SRV02 exists, but not vice-versa,
    # then changes made on SRV01 will be replicated to SRV02, but not the other way around.  This
    # usually is not an issue since the Add-DfsrConnection cmdlet adds two connections (one in
    # each direction) by default.  Each of the topologies demonstrated here add bidirectional
    # connections, so it does not apply here, but it is an important consideration when creating
    # custom topologies.
    if ($HubComputerName) {
        # A hub-and-spoke topology is where a hub member replicates with every other member in the
        # replication group (the spoke members).  It is useful when data is created on the hub
        # member and is replicated out to spoke members.  Although not shown here, this concept can
        # be modified to use multiple hub members.
        Write-Verbose "Configuring a hub-and-spoke connection topology"
        foreach ($spokeComputerName in $spokeComputerNames) {
            Write-Verbose "Adding bidirectional connections between the hub member computer named $HubComputer and the member computer named $spokeComputerName"
            $connection = Add-DfsrConnection -GroupName $GroupName -SourceComputerName $HubComputerName -DestinationComputerName $spokeComputerName
            Write-Output $connection
        }
    } else {
        # A full-mesh topology is where all members replicate with every other member in the
        # replication group.  It is useful when there are ten or fewer members.
        Write-Verbose "Configuring a full-mesh connection topology"
        for ($i = 0 ; $i -lt $allComputerNames.Count ; $i++) {
            for ($j = $i + 1 ; $j -lt $allComputerNames.Count ; $j++) {
                Write-Verbose ("Adding bidirectional connections between the member computers named {0} and {1}" -f $allComputerNames[$i],$allComputerNames[$j])
                $connection = Add-DfsrConnection -GroupName $GroupName -SourceComputerName $allComputerNames[$i] -DestinationComputerName $allComputerNames[$j]
                Write-Output $connection
            }
        }
    }

    # Set the content path and staging quota on all memberships
    # ---------------------------------------------------------
    # A membership contains the member-specific settings for a replicated folder.  When a
    # replicated folder is created, or a member is added to a replication group, one membership is
    # created on each member for each replicated folder.  There is no need to add a membership
    # explictly, and it cannot be removed by itself (it exists as long as the replicated folder and
    # the member are a part of the replication group).
    #
    # The content path is the location of a member computer's local copy of a replicated folder.
    #
    # The staging quota is the maximum size that the staging folder grows before purging the oldest
    # files.  This purging is done according to the staging cleanup percentages in the service
    # configuration settings (Get-DfsrServiceConfiguration).  The recommended value for the staging
    # quota for Windows Server 2012 R2 is 4 GB or the size of the 32 largest files in the
    # replicated folder, whichever is larger.
    #
    # Some may prefer using PowerShell splatting to pass multiple arguments to Set-DfsrMembership.
    # Instead, the simpler approach is used here for clarity.  For those that wish to customize this
    # script, the additional optional parameters to the Set-DfsrMembership cmdlet offer good
    # opportunities for extending the functionality of this script, as well as the use of
    # splatting.
    if ($StagingPathQuotaInMB -gt 0) {
        Write-Verbose "Setting the content path to '$ContentPath' and the staging path quota to $StagingPathQuotaInMB MB for the following member computers: $allComputerNames"
        $memberships = Set-DfsrMembership -GroupName $GroupName -FolderName $FolderName -ComputerName $allComputerNames -ContentPath $ContentPath -StagingPathQuotaInMB $StagingPathQuotaInMB -Force
    } else {
        Write-Verbose "Setting the content path to '$ContentPath' for the following member computers: $allComputerNames"
        $memberships = Set-DfsrMembership -GroupName $GroupName -FolderName $FolderName -ComputerName $allComputerNames -ContentPath $ContentPath -Force
    }
    Write-Output $memberships

    # Set the primary member
    # ----------------------
    # The primary member has the authoritative copy of data in its content path.  This means the
    # primary computer's copy of the data in the replicated folder will win conflicts during
    # initial sync.
    Write-Verbose ("Setting the primary member to be the computer named {0}" -f $PrimaryComputerName)
    $primaryMember = Set-DfsrMembership -GroupName $GroupName -FolderName $FolderName -ComputerName $PrimaryComputerName -PrimaryMember $true -Force
    Write-Output $primaryMember

    # Update the local copy of DFSR configuration on all members
    # ----------------------------------------------------------
    # DFSR AD configuration is cached on each member.  The cmdlets invoked above only update the
    # DFSR AD objects.  To avoid waiting for an automatic refresh, this command forces one
    # immediately on the member computers.
    Write-Verbose "Updating AD configuration on member computers: $allComputerNames"
    Update-DfsrConfigurationFromAD -ComputerName $allComputerNames
    Write-Verbose "Configuration complete.  Windows event 4104 will be written on each non-primary member computer when it completes initial sync."
} Finally {
    $ErrorActionPreference = $prevErrorActionPreference
    $ProgressPreference = $prevProgressPreference
}
