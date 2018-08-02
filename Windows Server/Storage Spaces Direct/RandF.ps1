$ServerList = "S2DCL01A", "S2DCL01B"
$FeatureList = "Failover-Clustering", "FS-FileServer", "RSAT-Clustering-PowerShell"

$scrBl={param($f) Install-WindowsFeature -Name $f }

Invoke-Command -ComputerName $ServerList -ScriptBlock $scrBl -ArgumentList (,$FeatureList) #argumentlist takes an array of parameters so we need to force this array to look as a single parameter otherwise the array elements will be considered each a parameter in the command