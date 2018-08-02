Enum CarColor
{
    Red
    Blue
    Black
    White
}

class Masina
{
    #Properties
    [string]$Firma
    [string]$Model
    [int]$Viteza
    [CarColor]$Color

    #Constructor
    Masina([string]$Firma, [string]$Model, [CarColor]$Color)
    {
        $this.Firma=$Firma
        $this.Model=$Model
        $this.Color=$Color
        $this.Viteza=0
    }

    #Method
    [void]MarireViteza([int]$v)
    {
        if(($this.Viteza+$v) -le 180)
        {
            $this.Viteza+=$v
        }
        else
        {
            Write-Error -Message "Cannot increase speed by $v as max speed would be reached"
        }
    }

    #Static method
    static [int]CalcGreutate([int]$Masa)
    {
        return $masa*10
    }
}