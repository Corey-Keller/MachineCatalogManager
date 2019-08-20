function Read-NumberInRange
{
    <#
  .SYNOPSIS
    Will get input from the user and ensure that it is an acceptable numeric value.
  .DESCRIPTION
    Long Will get input from the user and ensure that it is an acceptable numeric value.
  .PARAMETER Range
    The range of values to allow (from negative $Range to positive $Range)
  .PARAMETER Min
    The Minimum value to allow. If not set, defaults to -32768
  .PARAMETER Max
    The Maximum value to allow. If not set, defaults to 32767
  .PARAMETER AllowZero
    Switch to allow zero (0) as a value.
  .EXAMPLE
    PS C:\> Read-NumberInRange -Range 12
    Will accept any number from -12 to 12, excluding 0.
  .EXAMPLE
    PS C:\> Read-NumberInRange -Min -23 -max 47
    Will accept any number from -23 to 47, excluding 0.
  .EXAMPLE
    PS C:\> Read-NumberInRange -Min -237
    Will accept any number from -237 to 32767, excluding 0
  .EXAMPLE
    PS C:\> Read-NumberInRange -Min -237 -AllowZero
    Will accept any number from -237 to 32767
  .LINK
    https://github.com/Corey-Keller/MachineCatalogManager/tree/master/docs
  .INPUTS
    None.
  .OUTPUTS
    Integer
  .NOTES
    General notes
  #>
    [CmdletBinding(HelpURI = "https://github.com/Corey-Keller/MachineCatalogManager/tree/master/docs")
    param (
        # Parameter help description
        [Parameter(ParameterSetName = "Range")]
        [uint16] $Range,
        # Parameter help description
        [Parameter(ParameterSetName = "ExplicitMinMax")]
        [int16] $Min = [int16]::MinValue,
        [Parameter(ParameterSetName = "ExplicitMinMax")]
        [int16] $Max = [int16]::MaxValue,
        [switch] $AllowZero

    )

    if ($Range)
    {
        $min = $Range * - 1 # Since $Range is an unsigned int it will always be positive, so no need to test it as below
        $max = $Range
    }
    elseif ($Min -gt $Max)
    {
        $tempNum = $Min
        $Min = $Max
        $Max = $tempNum
        $PSBoundParameters["Min"] = $Min
        $PSBoundParameters["Max"] = $Max
    }
    #
    Write-Output "[NOTE]: Negative numbers will leave that many servers out of Maintenance Mode, and put the rest in Maintenance Mode"
    try
    {
        [int16]$ChosenNumber = Read-Host -Prompt "Please enter a new number"
        if (-not (($ChosenNumber -ge $Min) -and ($ChosenNumber -le $Max)))
        {
            throw "Value was either too large or too small for the required range"
        }
        elseif (($ChosenNumber -eq 0) -and (-not $AllowZero))
        {
            throw "Zero is not an allowed value"
        }

    }
    catch [System.Management.Automation.ArgumentTransformationMetadataException], [System.Management.Automation.RuntimeException]
    {
        $Caught = $_
        if ($Caught.Exception.Message -imatch "Value was either too large or too small for")
        {
            if (-not $AllowZero)
            {
                Write-Output "ERROR: Input was out of bounds (i.e. not between $min and $max excluding 0). Please try again."
            }
            else
            {
                Write-Output "ERROR: Input was out of bounds (i.e. not between $min and $max). Please try again."
            }
        }
        elseif ($Caught.Exception.Message -imatch "Input string was not in a correct format")
        {
            Write-Output "ERROR: Input was not a number. Please try again."
        }
        elseif ($Caught.Exception.Message -imatch "Zero is not an allowed value")
        {
            Write-Output "ERROR: Input was out of bounds (i.e. not between $min and $max excluding 0). Please try again."
        }
        else
        {
            Write-Output "An unknown error occured. Exiting"
            exit 77
        }
        Read-NumberInRange @PSBoundParameters
    }
    return $ChosenNumber
}