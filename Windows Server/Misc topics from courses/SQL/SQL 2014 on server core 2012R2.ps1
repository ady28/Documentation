#Install .NET 3.5 on the client machine (Win 10) with a DVD at D:\
Add-WindowsCapability –Online -Name NetFx3~~~~ –Source D:\sources\sxs
#Then install the management tools basic and management tools complete

#Install .NET 3.5 on the server core machine
Install-WindowsFeature NET-Framework-Core -Source E:\sources\sxs

#Create an INI file with the following content
[OPTIONS]
ACTION="Install"
FEATURES=SQLENGINE
INSTANCENAME="SQLExpress"
INSTANCEID="SQLExpress"
SQLSYSADMINACCOUNTS="testcorp1\administrator"
IAcceptSQLServerLicenseTerms="True"
TCPENABLED=1
BROWSERSVCSTARTUPTYPE="Automatic"
UPDATEENABLED=False

#Run the setup
Start-Process -FilePath 'C:\SQLSetup.exe' -ArgumentList '/Q','/ConfigurationFile=C:\SQLSettings.ini' -Wait

#Install the 3 extra msi files
Start-Process -FilePath 'msiexec' -ArgumentList '/i C:\SharedManagementObjects_x64.msi','/q' -Wait
Start-Process -FilePath 'msiexec' -ArgumentList '/i C:\PowershellTools_x64.msi','/q' -Wait
Start-Process -FilePath 'msiexec' -ArgumentList '/i C:\MsSqlCmdLnUtils_x64.msi','/q','/passive','IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES' -Wait

#Enable firewall rules for the sql instance and sql browser
New-NetFirewallRule -Name "SQL Server" -DisplayName "SQL Server" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1433
New-NetFirewallRule -Name "SQL Browser" -DisplayName "SQL Browser" -Profile Any -Direction Inbound -Action Allow -Protocol UDP -LocalPort 1434

#Enable SQL server remote management
#Create an SQL file with the following
EXEC sys.sp_configure N'remote access', N'1'
RECONFIGURE WITH OVERRIDE
#Run the script
Start-Process -FilePath 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\sqlcmd.exe' -ArgumentList '-S BCS01\SQLExpress','-i C:\RemoteSQL.sql' -Wait

#Configure SQL to listen on the 1433 port and not a dynamic TCP port
Import-Module 'C:\Program Files\Microsoft SQL Server\120\Tools\PowerShell\Modules\SQLPS'
$MachineObject = new-object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') "BCS01"
$instance = $MachineObject.getSmoObject("ManagedComputer[@Name='BCS01']/ServerInstance[@Name='SQLExpress']")
$instance.ServerProtocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpPort'].Value = "1433"
$instance.ServerProtocols['Tcp'].IPAddresses['IPAll'].IPAddressProperties['TcpDynamicPorts'].Value = ""
$instance.ServerProtocols['Tcp'].Alter()

#Restart the instance and the browser services
Restart-Service MSSQL`$SQLEXPRESS
Restart-Service SQLBrowser

#Connect to the instance from a management studio
