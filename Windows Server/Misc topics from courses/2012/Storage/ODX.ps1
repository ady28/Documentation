#Get ODX status 0-enabled 1-disabled
Get-ItemProperty hklm:\system\currentcontrolset\control\filesystem -Name "FilterSupportedFeaturesMode" | Select -ExpandProperty FilterSupportedFeaturesMode

#Disable ODX
Set-ItemProperty hklm:\system\currentcontrolset\control\filesystem -Name "FilterSupportedFeaturesMode" -Value 1
Restart-Computer
#Enable ODX
Set-ItemProperty hklm:\system\currentcontrolset\control\filesystem -Name "FilterSupportedFeaturesMode" -Value 0
Restart-Computer