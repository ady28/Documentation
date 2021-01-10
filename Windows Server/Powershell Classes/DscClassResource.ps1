Enum Ensure
{
    Present
    Absent
}

[DscResource()]
Class MyFile
{
    [DscProperty(Key)]
    [string]$Destination

    [DscProperty()]
    [Ensure]$Ensure

    [DscProperty(Mandatory)]
    [string]$Source

    [void]Set()
    {
        $File=Test-Path -Path $this.Destination
        if($this.Ensure -eq [Ensure]::Present)
        {
            if(!$File)
            {
                Copy-Item -Path $this.Source -Destination $this.Destination
            }
        }
        else
        {
            if($File)
            {
                Remove-Item -Path $this.Destination
            }
        }
    }

    [MyFile]Get()
    {
        if(Test-Path $this.Destination)
        {
            $EnsureValue=[Ensure]::Present
        }
        else
        {
            $EnsureValue=[Ensure]::Absent
        }

        $Obj=@{
            Source=$this.Source
            Destination=$this.Destination
            Ensure=$EnsureValue
        }
        return $Obj
    }

    [bool]Test()
    {
        if($this.Ensure -eq [Ensure]::Present)
        {
            return Test-path -Path $this.Destination
        }
        else
        {
            return !(Test-Path -Path $this.Destination)
        }
    }
}