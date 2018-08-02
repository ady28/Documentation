#Reset error color and view to default
function Reset-DefaultError
{
    $psISE.Options.ErrorForegroundColor = '#FFFF0000'
    $global:ErrorView = 'NormalView'
}

#Change error color and view (color change works only in ise)
$psISE.Options.ErrorForegroundColor = 'Chartreuse'
$ErrorView =  'CategoryView'

#Show errors in groups
$error | Group-Object | Sort-Object Count -Descending | Select-Object Count,Name