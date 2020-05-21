#Enable the virtual adfapter performance filter if not enabled
Set-NetAdapterBinding -ComponentID ms_netftflt -Name Ethernet -Enabled $true