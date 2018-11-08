<#
    .SYNOPSIS
      Parses an MDT log file and transforms each line and its metadata into objects
    .DESCRIPTION
      This function reads a standard MDT log file line by line and transforms each line
    and its metadata into an object. This function does not work for the Panther logs 
    and NetSetup log
    .PARAMETER FilePath
      Specify the full path to the file (Eg: C:\MDTLogs\BDD.log) or the relative path
    depending on where you are on the filesystem with the Powershell console
    (Eg: .\BDD.log)
    .PARAMETER ErrorOnly
      Use this switch if you want to get only lines that are categorized as errors
    .EXAMPLE
      Get-MDTLog -FilePath D:\MDTLogs\TESTPC\BDD.log

    .EXAMPLE
      Get-MDTLog -FilePath .\LiteTouch.log -ErrorOnly

#>
Function Get-MDTLog
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="Full path to the log file")]
        [string]$FilePath,
        [switch]$ErrorOnly
    )

    if(!(Test-Path -Path $FilePath))
    {
        Write-Error -Message 'Path not found' -RecommendedAction 'Check that the file path is correct' -Category ObjectNotFound
        Exit
    }

    if($ErrorOnly)
    {
        Write-Verbose "Only errors will be shown"
    }

    $Lines=Get-Content -Path $FilePath
    Write-Verbose "File has $($Lines.Count) lines. Iterating through each one"
    foreach($Line in $Lines)
    {
        #In case a line continues to the next line just save the text and concatenate it in the next iteration
        if($Line.EndsWith('>'))
        {
            if($GetNextLine -eq $true)
            {
                $GetNextLine=$false
                $Line=$NextLineText+$Line
                $NextLineText=''
            }
        }
        else
        {
            Write-Verbose "Current line continues on the next one. Will concatenate."
            $GetNextLine=$true
            $NextLineText=$Line
            Continue
        }

        #Split the message from the metadata part
        $FirstComponents=$Line.replace('<![LOG[','').replace(']LOG]!>','').TrimStart('<').Replace('<>','!=').Replace('<servicing>','servicing').split('<')

        #Get metadata components
        $SecondComponents=$FirstComponents[1].Replace('>','').Split(' ')
        $Time=$SecondComponents[0].Split('.')[0].Replace('time="','')
        $Date=$SecondComponents[1].Replace('date="','').Replace('"','')
        $DateTime="$Date $Time"
        $Component=$SecondComponents[2].Replace('component="','').Replace('"','')
        $Context=$SecondComponents[3].Replace('context="','').Replace('"','')
        $Type=$SecondComponents[4].Replace('type="','').Replace('"','')
        $Thread=$SecondComponents[5].Replace('thread="','').Replace('"','')
        $File=$SecondComponents[6].Replace('file="','').Replace('"','')

        #Form the output object
        $Properties=@{
            Message=$FirstComponents[0].TrimEnd('>')
            DateTime=[datetime]$DateTime
            Component=$Component
            Context=$Context
            Type=$Type
            Thread=$Thread
            File=$File
        }

        $Obj=New-Object PSObject -Property $Properties
        #Send object to pipeline if ErrorOnly is false or if it is true and this is an error
        if(($ErrorOnly -eq $true -and $Obj.Type -eq 3) -or ($ErrorOnly -eq $false))
        {
            Write-Output $Obj
        }
    }
}

Function Get-MDTLogPanther
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    if(!(Test-Path -Path $FilePath))
    {
        Write-Error -Message 'Path not found' -RecommendedAction 'Check that the file path is correct'
    }

    $Lines=Get-Content -Path $FilePath
    Write-Verbose "File has $($Lines.Count) lines. Iterating through each one."

    foreach($Line in $Lines)
    {
        
    }

}

Function Get-MDTLogNetSetup
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    if(!(Test-Path -Path $FilePath))
    {
        Write-Error -Message 'Path not found' -RecommendedAction 'Check that the file path is correct'
    }

    $Lines=Get-Content -Path $FilePath
    Write-Verbose "File has $($Lines.Count) lines. Iterating through each one."

    foreach($Line in $Lines)
    {
        $Matches.Clear()
        $Line -match "(?<Date>\d\d/\d\d/\d\d\d\d) (?<Time>\d\d:\d\d:\d\d):\d\d\d\s+(?<Message>.+)" | Out-Null
        if($Matches.Count -gt 0)
        {
            $Properties=@{
                DateTime = [datetime]"$($Matches.Date)  $($Matches.Time)"
                Message = $Matches.Message
            }
        }
        else
        {
            Write-Verbose "Found a line without date."
            $Properties=@{
                DateTime = $null
                Message = $Line
            }
        }
        $Obj=New-Object PSObject -Property $Properties
        Write-Output $Obj
    }
}