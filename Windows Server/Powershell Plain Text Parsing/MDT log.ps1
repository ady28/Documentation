$Lines=Get-Content .\BDD.log
foreach($Line in $Lines)
{
    #In case a line continues to the next line just save the text and concatenate it next iteration
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
    $Obj=New-Object PSCustomObject -Property $Properties
    Write-Output $Obj
}