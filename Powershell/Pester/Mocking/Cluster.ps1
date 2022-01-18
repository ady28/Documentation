function Restart-Cluster
{
    param([string]$Name)

    #Do what it takes to restart the cluster
}

function Test-Cluster
{
    param([string]$Name)

    $true
}

function Start-ClusterTest
{
    param([string]$Name)

    $Result=Test-Cluster -Name $Name

    if($Result)
    {
        $true
    }
    else
    {
        Restart-Cluster -Name $Name
    }
}