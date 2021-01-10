#Create a simple claim type for the tile AD atribute
New-ADClaimType title -SourceAttribute title

#Create a resource property to set on the folders linked with the claim type
New-ADResourceProperty Title -IsSecured $true -ResourcePropertyValueType MS-DS-MultivaluedText
Add-ADResourcePropertyListMember "Global Resource Property List" -Members Title

#To be added code for creating central access rule


#create a central access policy and add the access rule to it
New-ADCentralAccessPolicy -Description "Policy for controlling access to the O folder" -Name 'O folder access policy'
Add-ADCentralAccessPolicyMember -Identity 'O folder access policy' -Members 'Upper Management (Officers) Document Access'

#On a file server with the fs resource manager installed
Update-FSRMClassificationpropertyDefinition