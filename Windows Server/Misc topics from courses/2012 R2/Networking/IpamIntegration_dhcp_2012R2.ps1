[ScriptBlock] $sc = {
           
<#
  Windows IPAM Address Space Integration Cmdlet Module
  This module contains cmdlet for Invoke-IpamDhcpLease
 #>


function Invoke-IpamDhcpLease
{
<#     
    Input Parameters:
        ${IpamServerName}: Ipam Server name. This is a mandatory parameter.   
        ${DhcpServerFqdn}: Name of the DHCPServer from which leases will be imported. localhost is used by default
        ${AddressFamily}: Selection for the address space between IPv4 and/or IPv6 address space. Default scope is 'All'.
        ${CustomData}: Switch to indicate if the additional fields need to be imported along with range and address objects
        ${Periodic}: Switch to indicate if the address space is to be done one time or invoked periodically using scheduled task.
        $(Credential): Credential under which the scheduled task needs to run. This is mandatory for periodic import.
        ${Taskname}: Optional name of the scheduled task to be set-up if periodic import type is selected.
	    ${HoursInterval}: Number of hours after which the scheduled task should get triggered in a day, to perform import
        ${At}: Date and time at which the scheduled task should get triggered. Default is current time.
        ${Force}: If given, default confirmation will not be shown        
#>    

#region Param declarations
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName ='OneTime')]    
    Param(        
        [Parameter(Mandatory = $true, ParameterSetName='OneTime', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName='Periodic', Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${IpamServerName},

        [Parameter(Mandatory = $true, ParameterSetName='Periodic', Position = 1)]
        [ValidateNotNullOrEmpty()]
        [switch]
        ${Periodic},

        [Parameter(ParameterSetName='OneTime')]
        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${DhcpServerFqdn}=$([System.Net.Dns]::GetHostByName("localhost").HostName),

        [Parameter(Mandatory = $true, ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [PsCredential]
        ${Credential},

        [Parameter(ParameterSetName='OneTime')]        
        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
	    [ValidateSet('IPv4','IPv6','All')]
        [string]
        ${AddressFamily}="All",

        [Parameter(ParameterSetName='OneTime')]        
        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [switch]
        ${ReservationOnly},

        [Parameter(ParameterSetName='OneTime')]        
        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [switch]
        ${CustomData},
 
        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [string]
        ${TaskName}=$DEFAULT_TASK_NAME,

        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [uint32]
        ${HoursInterval}=$DEFAULT_TASK_HOURS_INTERVAL,

        [Parameter(ParameterSetName='Periodic')]
        [ValidateNotNullOrEmpty()]
        [datetime]
        ${At}=$(get-date),

        [Parameter()]
        [switch]
        ${Force}
    )
#endregion
    
Process {
    
       $script:PsSession=$NULL
        try 
        {
            #Import DHCP Server powershell module
            ipmo DhcpServer -ErrorAction Stop
        }
        catch { 
            Write-Debug "Invoke-IpamDhcpLease inserting DHCPServer PS module - Catch" $true
            $errMsg  = ($_system_translations.ErrorMsgDhcpInsertFailed -f $_.ToString())            
            ThrowTEException $errMsg $_.Exception
        }
       
        try 
        {
        
            $i = ${DhcpServerFqdn}.IndexOf(".")
            if ($i -le 0) 
            {		
    	        $errMsg = ($_system_translations.MsgIpamIntegrationActivity -f ${DhcpServerFqdn})
    	        ThrowTEException $errMsg $EC_InvalidArgument InvalidArgument
            }

            if (!(HandleImportShouldProcessAndShouldContinue)) { WriteTraceMessage "ShouldProcess returned false .. exiting"; return }            
            
            #Make the CP as high so that we dont get any confirm prompt for calls before our own SP/SC calls
            set-variable -name ConfirmPreference -scope 0 -value ([System.Management.Automation.ConfirmImpact]$ConfirmImpactHigh) -Confirm:$false
            WriteTraceMessage "Invoke-IpamDhcpLease Process - Start"
            Write-Progress -Activity $_system_translations.MsgIpamIntegrationActivity -Status $_system_translations.MsgStartedStatus -Id 0
           
            # Perform data import
	        if(${Periodic}) {
                    IpamCreateIntegrationTask 
	        }
	        else {
                    $script:PsSession=New-PSSession -ComputerName ${IpamServerName} -ErrorAction Stop
                    Write-Progress -Activity $_system_translations.MsgIpamIntegrationActivity -Status $_system_translations.MsgGetPsSessionStatus
                    WriteTraceMessage "Invoke-IpamIntegration Process - Got PSSession from IPAM"
                    IpamCreateCustomFields
                    IpamIntegrationOneTime
	        }
        }
        catch { 
            WriteTraceMessage "Invoke-IpamDhcpLease Process - Catch" $true
            $PSCmdlet.ThrowTerminatingError($_) 
        }
        finally {
            #Cleanup the PS Session
            if($script:PsSession) { 
                Remove-PSSession $script:PsSession 
                WriteTraceMessage "Invoke-IpamDhcpLease Process - Removed PS Session" 
            }
        }

        WriteTraceMessage "Invoke-IpamDhcpLease Process - End"   
        Write-Progress -Activity $_system_translations.MsgIpamIntegrationActivity -Status $_system_translations.MsgCompletedStatus -Id 0        
    }
}

function IpamCreateCustomFields()
{
    if((${AddressFamily} -eq "All") -Or (${AddressFamily} -eq "IPv4")){
        AddIpamCustomFields $global:IpamV4AddressData
        if(${CustomData}){
            AddIpamCustomFields $global:IpamCustomV4AddressData
        }
    }

    if((${AddressFamily} -eq "All") -Or (${AddressFamily} -eq "IPv6")){
        AddIpamCustomFields $global:IpamV6AddressData
        if(${CustomData}){
            AddIpamCustomFields $global:IpamCustomV6AddressData
        }
    }
}

function AddIpamCustomFields ([Psobject[]] $AddressObjects)
{
    foreach($element in $AddressObjects)
    {
        if($element.IpamPropertyAction -eq "Add") {
            if($element.IpamValueAction -eq "Add") {
                    Invoke-Command -Session $script:PsSession -Command {param($Name) Add-IpamCustomField -Name $Name -Multivalue} -ArgumentList $element.IpamPropertyName -ErrorAction SilentlyContinue
            }else{
                    Invoke-Command -Session $script:PsSession -Command {param($Name) Add-IpamCustomField -Name $Name} -ArgumentList $element.IpamPropertyName -ErrorAction SilentlyContinue
            }
        }              
    }
}

function IpamCreateIntegrationTask()
{   
    WriteTraceMessage "IpamCreateIntegrationTask - Start"
    Write-Progress -Activity $_system_translations.MsgIntegrationTaskActivity -Status $_system_translations.MsgStartedStatus -Id 0     

    try
    {
        #Set UserName and Password as derived from the Credential
        $user = ${Credential}.UserName
        $password = ${Credential}.GetNetworkCredential().Password
    }
    catch
    {
        WriteTraceMessage "IpamCreateIntegrationTask, get username, password - Catch" $true
        $errMsg  = ($_system_translations.ErrorMsgGetUserAndPasswordFailed -f $_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }
    
    try
    {   
                 
        #Create the argumnet string for powershell.exe
        $CmdStr ="-ExecutionPolicy Bypass "
        $CmdStr += "-Command `"&{set-variable IpamRunAsElevation 0 -scope global;"
        $CmdStr += "ipmo $($MyInvocation.ScriptName);"
        $CmdStr += "set-variable IpamTraceLogFile 1 -scope global;"
        $CmdStr += "Invoke-IpamDhcpLease -IpamServerName ${IpamServerName} -Force"       
        if(${DhcpServerFqdn}) { $CmdStr += " -DhcpServerFqdn ${DhcpServerFqdn}" }
        if(${AddressFamily}) { $CmdStr += " -AddressFamily ${AddressFamily}" }
        if(${ReservationOnly}) { $CmdStr += " -ReservationOnly" }
        if(${CustomData}) { $CmdStr += " -CustomData" }
        $CmdStr += " >"+ $DEFAULT_TASKLOG_PATH +${TaskName}+"_log.txt"
        $CmdStr += "}`""

        $WorkingDirectory=((Split-Path -parent $MyInvocation.ScriptName)+"\")

        $RepetitionHours="PT"+${HoursInterval}+"H"
        $RepetitionDays="P1D"

        $FailedCmdName="Start-ScheduledTask"
        $Hostname = $Env:computername
    
        $command = 'powershell.exe' 
        $CommandArguments = $CmdStr
        $taskRunAsuser = $user

        if($password) {
            $taskRunasUserPwd = $password
        }
        else{
            $taskRunasUserPwd = $null
        }

        $service = new-object -com("Schedule.Service") 
        $service.Connect($Hostname) 
        $rootFolder = $service.GetFolder("\") 

        $taskDefinition = $service.NewTask(0) 
        $regInfo = $taskDefinition.RegistrationInfo 
        $regInfo.Description = 'IPAM-DHCP integration task' 
        $regInfo.Author = $taskRunAsuser 
        $settings = $taskDefinition.Settings 
        $settings.Enabled = $True 
        $settings.StartWhenAvailable = $True 
        $settings.Hidden = $False 

        $triggers = $taskDefinition.Triggers 
        $trigger = $triggers.Create(2) 

        $dtfi=new-object system.globalization.datetimeformatinfo
        $trigger.StartBoundary =${At}.ToString($dtfi.SortableDateTimePattern)
        $trigger.DaysInterval = 1 
        $trigger.Id = "DailyTriggerId" 
        $trigger.Enabled = $True 
        $trigger.Repetition.Interval=$RepetitionHours
        $trigger.Repetition.Duration=$RepetitionDays

        $Action = $taskDefinition.Actions.Create(0) 
        $Action.Path = $command 
        $Action.Arguments = $CommandArguments 
        $Action.WorkingDirectory = $WorkingDirectory 
        $rootFolder.RegisterTaskDefinition( ${TaskName}, $taskDefinition, 0x2, $taskRunAsuser , $taskRunasUserPwd , 1) >$NULL

        schtasks.exe /run /tn ${TaskName}

        Write-Progress -Activity $_system_translations.MsgIntegrationTaskActivity -Status $_system_translations.MsgIntegrationTaskRegistrationStatus -Id 0  
    }
    catch
    {      
        WriteTraceMessage "IpamCreateIntegrationTask - Catch" $true
        $errMsg  = ($_system_translations.ErrorMsgCreateIntgrationTaskFailed -f $FailedCmdName,$_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }

    Write-Progress -Activity $_system_translations.MsgIntegrationTaskActivity -Status $_system_translations.MsgCompletedStatus -Id 0
    WriteTraceMessage "IpamCreateIntegrationTask - End"
}

function IpamIntegrationOneTime()
{   
    WriteTraceMessage "IpamIntegrationOneTime - Start"
    
    try {
        $script:Path=Invoke-Command -Session $script:PsSession  -Command {[System.IO.Path]::GetTempPath()} -ErrorAction Stop
        WriteTraceMessage "IpamIntegrationOneTime, got temp path from IPAM, value - $script:Path"
        Write-Progress -Activity $_system_translations.MsgIpamIntegrationActivity -Status ($_system_translations.MsgGetCsvPathStatus -f $script:Path) -Id 0  
    }
    catch
    {
        # Rollback the changes in case there is any error        
        WriteTraceMessage "IpamIntegrationOneTime, get temp path from IPAM - Catch" $true   
        $errMsg  = ($_system_translations.ErrorMsgGetTempPathFromIpamFailed -f $_.ToString())            
        ThrowTEException $errMsg $_.Exception    
    }

    try
    {
        Write-Progress -Activity $_system_translations.MsgIpamIntegrationActivity -Status $_system_translations.MsgGetDhcpServerVersion -Id 0    
        Get-DhcpServerVersion -ComputerName ${DhcpServerFqdn} -ErrorAction Stop >$NULL
        WriteTraceMessage "IpamIntegrationOneTime, Got DHCP Server version"
    }
    catch
    {      
        WriteTraceMessage "IpamIntegrationOneTime, GetDhcpServerVersion - Catch" $true       
        $errMsg = ($_system_translations.ErrorMsgGetDhcpServerFailed -f $_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }

    try
    {       
        
        if((${AddressFamily} -eq "All") -Or (${AddressFamily} -eq "IPv4")) {
            $FailedCmdName="Get-DhcpServerv4Scope"
            Write-Progress -Activity $_system_translations.MsgGetDataActivity -Status $_system_translations.MsgGetDhcpScopev4 -Id 0
            $script:AllDhcpV4Scopes = Get-DhcpServerv4Scope -ComputerName ${DhcpServerFqdn} -ErrorAction Stop
            WriteTraceMessage "IpamIntegrationOneTime, Got DHCP V4 Scopes" 
        }

        if((${AddressFamily} -eq "All") -Or (${AddressFamily} -eq "IPv6")) {
            $FailedCmdName="Get-DhcpServerv6Scope"
            Write-Progress -Activity $_system_translations.MsgGetDataActivity -Status $_system_translations.MsgGetDhcpScopev6 -Id 0
            $script:AllDhcpV6Scopes = Get-DhcpServerv6Scope -ComputerName ${DhcpServerFqdn} -ErrorAction Stop
            WriteTraceMessage "IpamIntegrationOneTime, Got DHCP V6 Scopes" 
        }


    }
    catch {      
        WriteTraceMessage "IpamIntegrationOneTime, Get scope cmd execution for DHCP - Catch" $true   
        $errMsg  = ($_system_translations.ErrorMsgGetScopeDataFromDHCP -f $FailedCmdName,$_.ToString())            
        ThrowTEException $errMsg $_.Exception    
    }

    
    try
    {             
        WriteTraceMessage "`n=================IpamIntegrationOneTime, Data Import - Start=================" 
        if(($AddressFamily -eq "All") -Or ($AddressFamily -eq "IPv4")) {
            $FailedCmdName="ImportDhcpLeases -IPv4"
            WriteTraceMessage "`n`nIpamIntegrationOneTime, Import IPv4 Dhcp Leases - Start" 
            ImportDhcpLeases "IPv4"
            WriteTraceMessage "IpamIntegrationOneTime, Import IPv4 Dhcp Leases - End"      
        }

        if(($AddressFamily -eq "All") -Or ($AddressFamily -eq "IPv6")) {
            $FailedCmdName="ImportDhcpLeases -IPv6"
            WriteTraceMessage "`n`nIpamIntegrationOneTime, Import IPv6 Dhcp Leases - Start" 
            ImportDhcpLeases "IPv6"
            WriteTraceMessage "IpamIntegrationOneTime, Import IPv6 Dhcp Leases - End"       
        }
        WriteTraceMessage "=================IpamIntegrationOneTime, Data Import - End=================`n" 
    }
    catch
    {
        # Rollback the changes in case there is any error        
        WriteTraceMessage "IpamIntegrationOneTime, Importing data - Catch" $true  
        $errMsg  = ($_system_translations.ErrorMsgImportingDataFailed -f $FailedCmdName,$_.ToString())            
        ThrowTEException $errMsg $_.Exception    
    }

    WriteTraceMessage "IpamIntegrationOneTime - End"
    Write-Progress -Activity $_system_translations.MsgImportActivity -Status $_system_translations.MsgCompletedStatus -Id 0
}

function ImportDhcpLeases([string]$AddressFamily)
{

   #Get the first tuple if server name is provided in FQDN format and calculate the prefix for ManagedBYService Value
   $ManagedByService="MS DHCP"
   $ServiceInstance=${DhcpServerFqdn}

    try 
    {
        if($AddressFamily -eq "IPv4") {
            $AllDhcpScopes = $script:AllDhcpV4Scopes
        }
        elseif($AddressFamily -eq "IPv6") {
            $AllDhcpScopes = $script:AllDhcpV6Scopes
        }          

        # Iterate over all LogicalNetworks
        foreach($DhcpScope in $AllDhcpScopes) 
        {   
                        
            #Initialize address lease array
            $IPAddressLeasesToImport=@()

            if($AddressFamily -eq "IPv4") {
                if(${ReservationOnly}) {
                    #Initialize range object array 
                    $AllIPAddressLeases=Get-DhcpServerv4Lease -ComputerName ${DhcpServerFqdn} -ScopeId $DhcpScope.ScopeId -ErrorAction Stop|where {$_.AddressState -eq "ActiveReservation" -or $_.AddressState -eq "InactiveReservation"}
                    WriteTraceMessage "IpamIntegrationOneTime, Got DHCP V4 Reservation Leases" 
                }
                else{
                    #Initialize range object array
                    $AllIPAddressLeases=Get-DhcpServerv4Lease -ComputerName ${DhcpServerFqdn} -ScopeId $DhcpScope.ScopeId -ErrorAction Stop
                    WriteTraceMessage "IpamIntegrationOneTime, Got DHCP V4 Leases" 
                }
            }
            elseif($AddressFamily -eq "IPv6") {
                if(${ReservationOnly}) {
                    #Initialize range object array
                    $AllIPAddressLeases=Get-DhcpServerv6Lease -ComputerName ${DhcpServerFqdn} -Prefix $DhcpScope.Prefix -ErrorAction Stop | where {$_.LeaseExpiryTime -eq ""}
                    WriteTraceMessage "IpamIntegrationOneTime, Got DHCP V6 Reservation Leases" 
                }
                else {
                    $AllIPAddressLeases=Get-DhcpServerv6Lease -ComputerName ${DhcpServerFqdn} -Prefix $DhcpScope.Prefix -ErrorAction Stop
                    WriteTraceMessage "IpamIntegrationOneTime, Got DHCP V6 Leases" 
                }
            }
 
            WriteTraceMessage "`t`tImport Leases - Start" 

            # Iterate over all LogicalNetworkDefinitions
            foreach($IPAddressLease in $AllIPAddressLeases) 
            {
                #Create a new mapping IPAM Address object for import corresponding to this pool                
                $IPAddressLeasesToImport+= CreateIpamIpAddress $AddressFamily $ManagedByService $ServiceInstance $DhcpScope $IPAddressLease
                                            
            } # Iterate over all leases - End
           
 
            #Import IP address objects
            WriteTraceMessage "Started inventory import"     

            ImportAddressCsv $AddressFamily $ManagedByService $ServiceInstance $DhcpScope $IPAddressLeasesToImport
            
            WriteTraceMessage "`t`tImport Leases - End"     
        }# Iterate over all LogicalNetworks - End

    }
    catch 
    {
        WriteTraceMessage "ImportDhcpLeases $AddressFamily - Catch" $true   
        $errMsg  = ($_system_translations.ErrorMsgImportDhcpLeases   -f $AddressFamily,$_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }
}

function CreateIpamIpAddress([string]$AddressFamily, [string]$ManagedByService, [string]$ServiceInstance,`
[System.Object]$DhcpScope, [System.Object]$DhcpLease)
{
    #Accepted object types for this module
    $AcceptedObjectTypes=('DhcpScope','DhcpLease')

    #Create new adress object
    $IpAddressObject = New-Object PsObject
   
    #Add custom fields to basic fields to create IPAM object
    if($AddressFamily -eq "IPv4") {
        if(${CustomData} -eq $true) {$AllAddressData = $global:IpamV4AddressData+$global:IpamCustomV4AddressData}
        else{$AllAddressData = $global:IpamV4AddressData}
    }
    elseif($AddressFamily -eq "IPv6") {
        if(${CustomData} -eq $true) {$AllAddressData = $global:IpamV6AddressData+$global:IpamCustomV6AddressData}
        else{$AllAddressData = $global:IpamV6AddressData}
    }


    try {
        

        foreach($element in $AllAddressData) {
            $IpamFieldValue=""
            
            if($element.containskey("DhcpObjectName")) {
                if($element.DhcpObjectName -in $AcceptedObjectTypes) {
                    $DhcpObject=Invoke-Expression("$"+$element.DhcpObjectName)
                    if($element.DhcpPropertyName) {$DhcpProperty=$element.DhcpPropertyName;$IpamFieldValue=$DhcpObject.$DhcpProperty}
                }
                else {
                     $errMsg  = ($_system_translations.ErrorMsgUnexpectedObjectTypeFailed -f $element.DhcpObjectName,$_.ToString())            
                     ThrowTEException $errMsg $_.Exception
                }
            }
            elseif($element.containskey("Expression")) {
                if($element.Expression) {$IpamFieldValue=invoke-expression ($element.Expression)}               
            }
            elseif($element.containskey("Fixed")) {
            }

            Add-Member -InputObject $IpAddressObject -MemberType NoteProperty -Name $element.IpamPropertyName -Value $IpamFieldValue -Force -ErrorAction Stop
            if($element.IpamValueAction -eq "Add") {
                Invoke-Command -Session $script:PsSession -Command {param($Name,$Value) Add-IpamCustomValue -Name $Name -Value $Value} -ArgumentList $element.IpamPropertyName,$IpamFieldValue -ErrorAction SilentlyContinue
            }
        }
        Add-Member -InputObject $IpAddressObject -MemberType NoteProperty -Name "Managed by Service" -Value $ManagedByService -Force -ErrorAction Stop
        Add-Member -InputObject $IpAddressObject -MemberType NoteProperty -Name "Service Instance" -Value $ServiceInstance -Force -ErrorAction Stop
    }
    catch {
        WriteTraceMessage "CreateIpamIpAddress, Creating Object - Catch" $true       
        $errMsg  = ($_system_translations.ErrorMsgCreateObjectFailed -f $element[0],$element[1],$element[2],$_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }

    return $IpAddressObject
}

function SubnetMaskToSubnetLength_v4([string]$SubnetMask) {
    
    $SubnetLength = 0

    $SplitSubnet = $SubnetMask.Split(".")

    foreach($SubnetOctet in $SplitSubnet) {
        switch($SubnetOctet) {
            "255" {$SubnetLength+=8}
            "254" {$SubnetLength+=7}
            "252" {$SubnetLength+=6}
            "248" {$SubnetLength+=5}
            "240" {$SubnetLength+=4}
            "224" {$SubnetLength+=3}
            "192" {$SubnetLength+=2}
            "128" {$SubnetLength+=1}
            default {}
        }
    }

    return $SubnetLength
}

function GetPaddedPrefix_v6([string] $PrefixString) {

    $PrefixString = $PrefixString.TrimEnd(":")
    
    $PaddedPrefix = ""
    $tokens = $PrefixString.Split(":")
    foreach($token in $tokens) {
        while($token.Length -lt 4) {
            $token = "0" + $token 
        }
        $PaddedPrefix += $token
    }
    return $PaddedPrefix

}

function GetStartIPAddress_v6([string] $Prefix) {
    
    $PrefixString = $Prefix
    $PrefixString = GetPaddedPrefix_v6 $PrefixString

    while($PrefixString.Length -lt 32) {
        $PrefixString += "0"
    }

    $StartAddressString = $PrefixString.SubString(0, 16)

    $StartAddressLower = ([System.Int64] ("0x" + $PrefixString.SubString(16))) -bor 0x1

    $StartAddressLowerString = [convert]::ToString($StartAddressLower, 16)

    while($StartAddressLowerString.Length -lt 16) {
        $StartAddressLowerString = "0" + $StartAddressLowerString
    }

    $StartAddressString += $StartAddressLowerString

    $FormattedStartAddressString = ""
    $index = 0
    while($index -lt 32) {

        $FormattedStartAddressString += $StartAddressString.SubString($index, 4) + ":"
        $index += 4
    }

    $FormattedStartAddressString = $FormattedStartAddressString.TrimEnd(":")
    
    return $FormattedStartAddressString
}

function GetEndIPAddress_v6([string] $Prefix, [System.Int32] $PrefixLength) {

    $PrefixString = $Prefix
    $PrefixString = GetPaddedPrefix_v6 $PrefixString

    while($PrefixString.Length -lt 32) {
        $PrefixString += "0"
    }

    $NibblesInPrefix = [System.Int32] ($PrefixLength / 4)

    $SubnetMask = ""

    while($NibblesInPrefix -gt 0) {
        $SubnetMask += "f"
        $NibblesInPrefix -= 1
    }

    if(($PrefixLength % 4) -ne 0) {
        switch($PrefixLength % 4) {
            1 {$SubnetMask += "8"}
            2 {$SubnetMask += "c"}
            3 {$SubnetMask += "e"}
            0 {}
        }
    }

    while($SubnetMask.Length -lt 32) {
        $SubnetMask += "0"
    }

    $SubnetMaskComplimentHigher = -bNOT [System.Int64] ("0x" + $SubnetMask.SubString(0, 16))

    $PrefixStringHigher = [System.Int64] ("0x" + $PrefixString.SubString(0, 16))

    $EndAddressHigher = $PrefixStringHigher -bor $SubnetMaskComplimentHigher
    
    $EndAddressHigherString = [convert]::ToString($EndAddressHigher, 16)
    while($EndAddressHigherString.Length -lt 16) {
        $EndAddressHigherString = "0" + $EndAddressHigherString
    }

    $SubnetMaskComplimentLower = -bNOT [System.Int64] ("0x" + $SubnetMask.SubString(16))

    $PrefixStringLower = [System.Int64] ("0x" + $PrefixString.SubString(16))

    $EndAddressLower = $PrefixStringLower -bor $SubnetMaskComplimentLower

    $EndAddressLowerString = [convert]::ToString($EndAddressLower, 16)
    while($EndAddressLowerString.Length -lt 16) {
        $EndAddressLowerString = "0" + $EndAddressLowerString
    }

    $EndAddressString = $EndAddressHigherString + $EndAddressLowerString

    $FormattedEndAddressString = ""
    $index = 0
    while($index -lt 32) {

        $FormattedEndAddressString +=  $EndAddressString.SubString($index, 4) +":"
        $index += 4
    }

    $FormattedEndAddressString =     $FormattedEndAddressString.TrimEnd(":")
    
    return $FormattedEndAddressString
}

function ImportAddressCsv([string]$AddressFamily, [string]$ManagedByService, [string]$ServiceInstance,`
[PSObject]$DhcpScope, [Psobject[]]$IPAddressToImport)
{

    if($AddressFamily -eq "IPv4") {
        $DHCPScopeId = $DhcpScope.ScopeId.ToString()
        $V4ScopeSubnetLength=SubnetMaskToSubnetLength_v4 $DhcpScope.SubnetMask.ToString()
        $DhcpNetworkId=$DhcpScope.ScopeId.ToString() +"/"+$V4ScopeSubnetLength
        $DhcpStartAddress=$DhcpScope.StartRange
        $DhcpEndAddress=$DhcpScope.EndRange
    } else {
        $DHCPScopeId = GetPaddedPrefix_v6 $DhcpScope.Prefix.ToString()
        $DhcpNetworkId=$DhcpScope.Prefix.ToString()+"/"+$DhcpScope.PrefixLength.ToString()
        $DhcpStartAddress= GetStartIPAddress_v6 $DhcpScope.Prefix.ToString()
        $DhcpEndAddress= GetEndIPAddress_v6 $DhcpScope.Prefix.ToString() $DhcpScope.PrefixLength
    }

    try {
        
        $ManagedByService="MS DHCP"
        $ServiceInstance=${DhcpServerFqdn}
      
        $ExecutingCmd="Import of address data csvs"
        $IPAddressToImport| `
        Invoke-Command -Session $script:PsSession -Command {`
        param($mbs,$si,$af, $path, $name, $scopeid, $subnet, $startip, $endip, $tn, $dhcp) `
        $File=$path+$($dhcp+"_"+$tn+"_"+$mbs+"_"+$si+"_"+$scopeid+".csv"); `
        $input|export-csv -Path $File -encoding Unicode; `
        Import-IpamAddress -AddressFamily $af -Path $File -ManagedByService $mbs -ServiceInstance $si `
        -NetworkId $subnet -StartIpAddress $startip -EndIpAddress $endip -Force >$NULL`
        }-Argumentlist $ManagedByService, $ServiceInstance, $AddressFamily, $script:Path, $DhcpScope.Name,`
        $DHCPScopeId, $DhcpNetworkId,$DhcpStartAddress,$DhcpEndAddress, ${TaskName}, $DhcpServerFqdn  -ErrorAction Stop 
    }
    catch  {       
        WriteTraceMessage "ImportAddressCsv - Catch" $true       
        $errMsg  = ($_system_translations.ErrorMsgImportAddressCsvFailed -f $ExecutingCmd,$_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }

}


# Return $true if given input string is $null or EmptyString ("")
function IsNullOrEmptyString([string] $str) { return ($null -eq $str -or "" -eq $str) }    

#Handles the ShouldProcess and ShouldContinue
function HandleImportShouldProcessAndShouldContinue
{   
    if ($true -eq ${Periodic}) {
        $shouldProcesMsg    = $_system_translations.Msg_ShouldProcess_Periodic
        $shouldContinueMsg  = ($_system_translations.Msg_ShouldContinue_Periodic -f $_system_translations.ShouldContinueConfirmation) 
    }
    else {
        $shouldProcesMsg    = $_system_translations.Msg_ShouldProcess_OneTime
        $shouldContinueMsg  = ($_system_translations.Msg_ShouldContinue_OneTime -f $_system_translations.ShouldContinueConfirmation)         
    }
        
    $result = $PSCmdlet.ShouldProcess($shouldProcesMsg, $null, $null);
    if ($result -and (!${Force})) {
        $result = $PSCmdlet.ShouldContinue($shouldContinueMsg, $_system_translations.ShouldContinueCaption);
    }

    return $result;
}

function ThrowTEException([string]$errMessage, [System.Exception]$exp, [string] $errorId=([System.Management.Automation.ErrorCategory]::InvalidOperation).ToString(), [System.Management.Automation.ErrorCategory]$errorCategory=[System.Management.Automation.ErrorCategory]::InvalidOperation, [Object] $targetObject=$null)
{     
    $exception = New-Object System.Exception($errMessage, $exp)
    $err = New-Object System.Management.Automation.ErrorRecord  ( 
                                $exception,
                                $errorId,
                                $errorCategory,
                                $targetObject 
                             )
    throw $err    
}

# Helper function to write trace messages only when $global:IpamTraceMessage is set to $true
function WriteTraceMessage([string] $message, [bool]$isRed=$false) 
{
    
        [System.ConsoleColor] $color = [System.ConsoleColor]::Cyan
        
        if ($isRed) {
            if ($global:IpamTraceMessage) {
                $color = [System.ConsoleColor]::Red 
            }
            elseif ($global:IpamTraceLogFile) {
                $message= "Error!!!" + $message
            }
        }

        
        if ($global:IpamTraceMessage) {
            Write-Host -ForegroundColor $color $message
        }
        elseif ($global:IpamTraceLogFile) {
            $message=$(get-date).ToString()+" :" +$message
            Write-Output $message
        }
}

#region Constants
$script:DEFAULT_TASK_NAME="IpamDhcpIntegration"
$script:DEFAULT_TASK_HOURS_INTERVAL="6"
$script:DEFAULT_TCP_PORT="8100"
$script:DEFAULT_TASKLOG_PATH=($env:windir+"\temp\")
$script:EC_InvalidArgument=([System.Management.Automation.ErrorCategory]::InvalidArgument).ToString() 
$script:ConfirmImpactHigh="High"
#endregion


<#
Edit these customizable arrays to add new properties for import. Supported foramts are:
    - Format 1: Simple object-field pair of DHCP and the corresponding field name of IPAM object
                @{"IpamPropertyAction"=<>;"IpamValueAction"=<>;"IpamPropertyName"=<>;"DhcpObjectName"=<>;"DhcpPropertyName"=<>}
                                
    - Format 2: Expression that should be executed using invoke-expression to evaluate the IPAM object property name at run time. The first item of the tuple should be left empty in this format 
                @{"IpamPropertyAction"=<>;"IpamValueAction"=<>;"IpamPropertyName"=<>;"Expression"=<>}

Note that the property name for DHCP object i.e. "DhcpPropertyName" should be identical to the DHCP Powershell object's field name. 
Note that the Property name for IPAM object i.e. "IpamPropertyName" either should be identical to built-in fields or one may add custom field (and values) to enable import to cusotm information.
For values that will be fixed for all imported objects, such as Managed By Service, we will use the field "Fixed".

For adding free-form custom field set:
     "IpamPropertyAction" to "Add"
     "IpamValueAction" to empty ("")
For adding multi-valued custom fields and the corresponding custom values set:
     "IpamPropertyAction" to "Add" 
     "IpamValueAction" to "Add"
For adding custom values to pre-existing multi-valued custom fields set:
     "IpamPropertyAction" to empty ("")
     "IpamValueAction" to "Add"

Supported objects for Custom import are as follows :
    
    IP Address
    ----------
              #DHCPScope
              #DHCPLease

#>


$global:IpamCustomV4AddressData= (
#Format 1- @{"IpamPropertyAction"=<>;"IpamValueAction"=<>;"IpamPropertyName"=<>;"DhcpObjectName"=<>;"DhcpPropertyName"=<>}
#Format 2- @{"IpamPropertyAction"=<>;"IpamValueAction"=<>;"IpamPropertyName"=<>;"Expression"=<>}

                                ,('','','')
                            )

$global:IpamCustomV6AddressData= (
#Format 1- @{"IpamPropertyAction"=<>;"IpamValueAction"=<>;"IpamPropertyName"=<>;"DhcpObjectName"=<>;"DhcpPropertyName"=<>}
#Format 2- @{"IpamPropertyAction"=<>;"IpamValueAction"=<>;"IpamPropertyName"=<>;"Expression"=<>}
 
                                ,('','','')
                            )

<#
   Base Range and Address arrays being used for import
#>

$global:IpamV4AddressData=(
                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "IP Address"; 
                    "Expression"="`$DhcpLease.IPAddress.IPAddressToString" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Description"; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "Description" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= 'Client ID'; 
                    "Expression"="`$DhcpLease.ClientId -replace '-',''" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= 'Device Name'; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "HostName" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= 'Expiry Date'; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "LeaseExpiryTime" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = "Add"; "IpamPropertyName"= "Ip Address State"; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "AddressState" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Managed by Service"; 
                    "Fixed"="" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Service Instance"; 
                    "Fixed"="" }
    )  
    
$global:IpamV6AddressData=(
                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"="IP Address"; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "IPAddress" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Description"; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "Description" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= 'DUID'; 
                    "Expression"="`$DhcpLease.ClientDuid -replace '-',''" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= 'IAID'; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "Iaid" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Device Name"; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "HostName" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Expiry Date"; 
                    "DhcpObjectName"="DhcpLease"; "DhcpPropertyName" = "LeaseExpiryTime" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Managed by Service"; 
                    "Fixed"="" },

                @{"IpamPropertyAction" = ""; "IpamValueAction" = ""; "IpamPropertyName"= "Service Instance"; 
                    "Fixed"="" }
                
               
    )  


#region LocalizedString

# Localized strings

data _system_translations {
   ConvertFrom-StringData @'
   # fallback text goes here    
          
    #Error Msg
    ErrorMsgDhcpInsertFailed= Failed to insert virtualmachinemanager module. Ensure that DHCP console is installed on this machine.\n {0}
    ErrorMsgGetTempPathFromIpamFailed= Getting csv creation folder from IPAM server failed.\n {0}
    ErrorMsgGetDhcpServerFailed= Getting DHCP Server failed.\n {0}
    ErrorMsgGetUserAndPasswordFailed= Getting username and password from Credential failed. \n {0}
    ErrorMsgCreateIntgrationTaskFailed= PS cmd execution for Scheduled task failed. Cmd details: {0}.\n {1}
    ErrorMsgGetDataFromDhcp= PS Cmd execution for DHCP server to get data failed. Cmd details: {0}.\n {1}
    ErrorMsgImportingDataFailed= Importing data into IPAM failed for the operation - {0}.\n {1}
    ErrorMsgImportAddresses= Address data import for {0} address space of IP Pool {1} failed.\n {2}
    ErrorMsgImportAddressCsvFailed= Address data import as csvs failed.  Executing cmd - {0}.\n {1}
    ErrorMsgUnexpectedObjectTypeFailed= Unknown type {0} specified for creating IPAM object.\n {1}
    ErrorMsgCreateObjectFailed= Failure while creating IPAM object. DhcpObjectName {0}, FieldOrExpression {1}, IpamPropertyName {2}, IpamFieldValue {3}.\n {4}
    ErrorMsgGetScopeDataFromDHCP= PS Cmd execution for DHCP server to get scope data failed. Cmd details: {0}.\n {1}
    ErrorMsgImportDhcpLeases= Failure while importing {0} DHCP leases.\n {1}

    #ShouldProcess/ShouldContinue Messages
    Msg_ShouldProcess_Periodic= The Invoke-IpamIntegration cmdlet will create a  task to periodically import DHCP Lease information from DHCP to IPAM. You may choose to import address space only from Logical Networks or VM Networks or both.\n It is recommended that Network Service credentials are used to set up this task.
    Msg_ShouldProcess_OneTime= The Invoke-IpamIntegration cmdlet will import DHCP Lease information from DHCP to IPAM. You may choose to import address space only from Logical Networks or VM Networks or both.
    Msg_ShouldContinue_Periodic= The Invoke-IpamIntegration cmdlet will create a  task to periodically import DHCP Lease information from DHCP to IPAM. You may choose to import address space only from Logical Networks or VM Networks or both. \n It is recommended that Network Service credentials are used to set up this task.{0}
    Msg_ShouldContinue_OneTime= The Invoke-IpamIntegration cmdlet will import DHCP Lease information from DHCP to IPAM. You may choose to import address space only from Logical Networks or VM Networks or both. {0}
    ShouldContinueCaption= Confirm
    ShouldContinueConfirmation= Do you want to perform this action?

    #Progress-bar messages - Activity
    MsgIpamIntegrationActivity = Address space integration to IPAM 
        MsgStartedStatus= Started ...
        MsgCompletedStatus= Completed.

    MsgIntegrationTaskActivity= Creating IPAM integration task 
        MsgIntegrationTaskTriggerStatus= Scheduled task trigger created
        MsgIntegrationTaskActionStatus= Scheduled task action created
        MsgIntegrationTaskRegistrationStatus= Scheduled task registered

    MsgImportActivity= Importing address space 
        MsgGetPsSessionStatus= Established PS Session with IPAM Server
        MsgGetCsvPathStatus= Path to create csv files on IPAM Server - {0}
        MsgGetDhcpServerVersion= Getting DHCP Server version...
        MsgGetDhcpServerStatus= Getting DHCP Server connection...
    
    MsgImportLogicalNetworkActivity= Processing {0} Logical Network - {1}
        MsgProcessingLogicalNetworkDefinitionStatus= Processing Network Sites...
    
    MsgImportVmNetworkActivity= Processing {0} VM Network - {1}
        MsgProcessingVmSubnetStatus= Processing VM subnets...

    MsgImportLogicalNetworkDefinitionActivity= Processing {0} Network Site - {1}
    MsgImportVMSubnetActivity= Processing {0} VM Subnet - {1}
        MsgAddressPoolProgressStatus= IP Address Range import in progress...
        MsgAddressPoolProgressAddressPendingStatus= Address import pending. IP Address Range import in progress... 
        MsgAddressPoolCompleteAddressProgressStatus= IP Address Range import complete. Address import in progress for Pool - {0}...
        
    MsgGetDataActivity= Getting address space data from DHCP
        MsgGetAddressRelatedObjectsStatus= Getting address related objects {0} from DHCP...
        MsgGetDhcpScopev4= Getting IPv4 DHCP Scopes...
        MsgGetDhcpScopev6= Getting IPv6 DHCP Scopes...
        MsgGetIpPoolStatus= Getting {0} DHCP Scopes...
        MsgGetIpAddressStatus= Getting DHCP Leases for DHCP Scope - {0} ...
    
'@
}

#Import-LocalizedData -BindingVariable _system_translations -filename IpamIntegration.psd1

#endregion

[bool]$global:IpamTraceMessage = $false
[bool]$global:IpamTraceLogFile = $false

Set-StrictMode -Version 3

Export-ModuleMember -function Invoke-IpamDhcpLease
}


if(Test-Path variable:\IpamRunAsElevation) {
    $RunElevated = $global:IpamRunAsElevation
}
else {
    $RunElevated = $true
}

if($RunElevated -eq $true) 
{
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
    # Get the security principal for the Administrator role
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole) -eq $false)
    {
        # We are not running "as Administrator" - so relaunch as administrator

        $FileName = $($MyInvocation.MyCommand.Name)
        $WorkingDirectory=((Split-Path -parent $MyInvocation.MyCommand.Path)+"\")
        $Script=$($WorkingDirectory + $FileName)

        # Create a new process object that starts PowerShell
        $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $ProcessStartInfo.UseShellExecute = $True
        $ProcessStartInfo.WorkingDirectory = $WorkingDirectory
        $ProcessStartInfo.FileName =  "powershell.exe"
        $ProcessStartInfo.Arguments = "-NoProfile -NoExit -ExecutionPolicy `"Bypass`" -file `"$Script`""
        $ProcessStartInfo.Verb = "runas"
        
        [System.Diagnostics.Process]::Start($ProcessStartInfo) >$NULL
   
        # Exit from the current, unelevated, process
        Stop-Process $pid
   }
}

$mod = New-Module -Name "IpamDhcpLease" -ScriptBlock $sc
ipmo $mod -Global

Invoke-IpamDhcpLease -?