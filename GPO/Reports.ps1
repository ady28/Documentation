#Get a GPO
Get-GPO -Name Test1
#Get all GPOs
Get-GPO -All
#Get GPOs and just show name and status
Get-GPO -All | Select Displayname,gpostatus
#Get all GPOs with wmi filters
Get-GPO -All | Where-Object {$_.WmiFilter}
#Get GPOs and sort
Get-gpo -All | Sort-Object CreationTime,ModificationTime | Select-Object DisplayName,*Time
#Get the entities on whic a gpo is applied
$a=Get-GPO -Name Test1
$a.GetSecurityInfo() | where {$_.Permission -eq 'GPOApply'}
#Get and export an html gpo report
Get-GPOReport -Name Test1 -ReportType Html -Path C:\Users\Administrator\Desktop\Test1.HTML
#Get a gpo as an xml object
[xml](Get-GPOReport -Name Test1 -ReportType Xml)

#Check is a GPO is empty
[xml]$report=Get-GPOReport -Name Test8 -ReportType XML
if ((-Not $report.gpo.user.extensiondata) -AND (-not $report.gpo.computer.extensiondata))
{
    $true
}
else
{
    $false
}

#For a GPO show separately the user and computer parts if empty or not
$User=$False
$Computer=$False
[xml]$report=Get-GPOReport -Name Test2 -ReportType XML
if($report.gpo.user.extensiondata)
{
    $User=$True
}
If($report.gpo.computer.extensiondata)
{
    $Computer=$True
}
New-Object -TypeName PSObject -Property @{
    Displayname=$report.gpo.name
    UserData=$User
    ComputerData=$Computer
}

#Test if a GPO has unrecognized registry settings
#This can happen if a GPO uses an ADMX that either does not exist anymore in the domain or is not imported in that GPO
[xml]$report=Get-GPOReport -Name Test1 -ReportType XML
$ns=@{q3="http://www.microsoft.com/GroupPolicy/Settings/Registry"}
$nodes=Select-Xml -Xml $report -Namespace $ns -XPath "//q3:RegistrySetting" | select -expand Node | Where {$_.AdmSetting -eq 'false'}
if ($nodes) {
  Get-GPO -Name Test1
}

#Get GPO links
#define a REGEX pattern for a GUID
[Regex]$RegEx = "(([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12})"
#create an array of distinguishednames
$dn=@()
$dn+=Get-ADDomain | select -ExpandProperty DistinguishedName
$dn+=Get-ADOrganizationalUnit -filter * | select -ExpandProperty DistinguishedName    
foreach ($container in $dn)
{
    Get-ADObject -identity $container -properties gplink | Where {$_.GPLink} | foreach {
        $linkData=$_.gplink.split("][") | Where {$_}
        foreach ($item in $linkdata) {
         <#
          split the linkdata. Item 0 will contain the GPO GUI
          and Item 1 will contain an value indicating if the link is
          enabled or not and enforced or not
                Enforced  LinkEnabled
              0 no		    yes
              1 no		    no
              2 yes		    yes
              3 yes		    no     
         #>
         $gpodata=$item.split(";")
         $guid=$Regex.match($gpodata[0]).Value
         $gponame=(Get-GPO -Guid $guid).Displayname
         Switch ($gpodata[1]) {
            0 {$Link=$True;$Enforced=$False}
            1 {$Link=$False;$Enforced=$False}
            2 {$Link=$True;$Enforced=$True}
            3 {$Link=$False;$Enforced=$True}
         } #switch
         New-Object -TypeName PSObject -Property @{
            Container=$Container
            Name=$gponame
            ID=$guid
            LinkEnabled=$Link
            Enforced=$Enforced
         } | Select Container,Name,ID,LinkEnabled,Enforced
    } #foreach item
    } #foreach linkdata
} #foreach container

#Get unlinked GPOs
#GUID regular expression pattern
[Regex]$RegEx = "(([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12})"
#create an array of distinguishednames
$dn=@()
$dn+=Get-ADDomain | select -ExpandProperty DistinguishedName
$dn+=Get-ADOrganizationalUnit -filter * | select -ExpandProperty DistinguishedName
$links=@()
#get domain and OU links
foreach ($container in $dn)
{
    get-adobject -identity $container -prop gplink | where {$_.gplink} | Select -expand gplink | foreach {
      #there might be multiple GPO links so split  
      foreach ($item in ($_.Split("]["))) {
        $links+=$regex.match($item).Value
      } #foreach item
    } #foreach
} #foreach container
Get-GPO -All | Where {$links -notcontains $_.id} 