Function New-Popup
{
    <#
  .SYNOPSIS
    Display a Popup Message
  .DESCRIPTION
    This command uses the Wscript.Shell PopUp method to display a graphical message
    box. You can customize its appearance of icons and buttons. By default the user
    must click a button to dismiss but you can set a timeout value in seconds to
    automatically dismiss the popup.

    The command will write the return value of the clicked button to the pipeline:
      OK     = 1
      Cancel = 2
      Abort  = 3
      Retry  = 4
      Ignore = 5
      Yes    = 6
      No     = 7

    If no button is clicked, the return value is -1.
  .EXAMPLE
    PS C:\> new-popup -message "The update script has completed" -title "Finished" -time 5

    This will display a popup message using the default OK button and default
    Information icon. The popup will automatically dismiss after 5 seconds.
  .NOTES
  Last Updated: April 8, 2013
  Version     : 1.0
  .INPUTS
    None
  .OUTPUTS
    integer

    Null   = -1
    OK     = 1
    Cancel = 2
    Abort  = 3
    Retry  = 4
    Ignore = 5
    Yes    = 6
    No     = 7
  .LINK
    http://machinecatalogmanager.readthedocs.io/en/latest/functions/New-Popup.md
  .LINK
    https://github.com/Corey-Keller/MachineCatalogManager/blob/master/MachineCatalogManager/Private/New-Popup.ps1

  #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = "None", HelpURI = "http://machinecatalogmanager.readthedocs.io/en/latest/functions/New-Popup.md")]
    Param (
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Enter a message for the popup")]
        [ValidateNotNullorEmpty()]
        [string]$Message,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Enter a title for the popup")]
        [ValidateNotNullorEmpty()]
        [string]$Title,
        [Parameter(Position = 2, HelpMessage = "How many seconds to display? Use 0 require a button click.")]
        [ValidateScript( { $_ -ge 0 })]
        [int]$Time = 0,
        [Parameter(Position = 3, HelpMessage = "Enter a button group")]
        [ValidateNotNullorEmpty()]
        [ValidateSet("OK", "OKCancel", "AbortRetryIgnore", "YesNo", "YesNoCancel", "RetryCancel")]
        [string]$Buttons = "OK",
        [Parameter(Position = 4, HelpMessage = "Enter an icon set")]
        [ValidateNotNullorEmpty()]
        [ValidateSet("Stop", "Question", "Exclamation", "Information" )]
        [string]$Icon = "Information"
    )
    if ($PSCmdlet.ShouldProcess("Generate Popup?"))
    {
        #convert buttons to their integer equivalents
        Switch ($Buttons)
        {
            "OK" { $ButtonValue = 0 }
            "OKCancel" { $ButtonValue = 1 }
            "AbortRetryIgnore" { $ButtonValue = 2 }
            "YesNo" { $ButtonValue = 4 }
            "YesNoCancel" { $ButtonValue = 3 }
            "RetryCancel" { $ButtonValue = 5 }
        }

        #set an integer value for Icon type
        Switch ($Icon)
        {
            "Stop" { $iconValue = 16 }
            "Question" { $iconValue = 32 }
            "Exclamation" { $iconValue = 48 }
            "Information" { $iconValue = 64 }
        }

        #create the COM Object
        Try
        {
            $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
            #Button and icon type values are added together to create an integer value
            $wshell.Popup($Message, $Time, $Title, $ButtonValue + $iconValue)
        }
        Catch
        {
            #You should never really run into an exception in normal usage
            Write-Warning "Failed to create Wscript.Shell COM object"
            Write-Warning $_.exception.message
        }

    }

} #end function
