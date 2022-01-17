function Test-Foo
{
    param([string]$FilePAth)

    if((Get-Content $FilePAth) -eq 'foo')
    {
        $true
    }
    else
    {
        $false
    }
}