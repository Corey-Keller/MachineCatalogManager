function Set-ServersInMaintenanceMode
{
<#
.SYNOPSIS
  Set servers in a given Machine Catalog into Maintenance Mode.
.DESCRIPTION
  Set servers in a given Machine Catalog (MC) into Maintenance Mode (MM).
.PARAMETER MachineCatalog
  The Machine Catalog you're working with, i.e "M4298_MC" or "C289_RevCycle_MC" This parameter is Mandatory.
.PARAMETER Count
  The number of servers to put into Maintenance Mode (MM) (i.e. 5). If negative (i.e. -4) it will keep that many servers out of MM and add the rest.
.PARAMETER Flip
  Will flip the Maintenance Mode state (On to Off and vice versa) of all servers in the Machine Catalog
.PARAMETER All
  Will specifically put ALL servers in the Machine Catalog into Maintenance Mode without the prompts to make sure. USE WITH CAUTION!
.EXAMPLE
  PS C:\> Set-ServersInMaintenanceMode -MachineCatalog B289A_MC
  Will set the default number of servers into Maintenance Mode (currently one half of the number in the Catalog)
.EXAMPLE
  PS C:\> Set-ServersInMaintenanceMode -MachineCatalog C289_MC -Count 4
  Will put a specific number of servers (4 in this case) in Maintenance Mode
.EXAMPLE
  PS C:\> Set-ServersInMaintenanceMode -MachineCatalog P289_MC -Count -3
  Will keep a specific number of servers (3 in this case) out of Maintenance Mode, and put the rest into Maintenance Mode
.EXAMPLE
  PS C:\> Set-ServersInMaintenanceMode -MachineCatalog B289A_MC -Flip
  Will set any servers with Maintenance Mode On to Off, and all Off servers to On
.EXAMPLE
  PS C:\> Set-ServersInMaintenanceMode -MachineCatalog T4298_MC -All
  Will set all servers into Maintenance Mode without prompting the user to double check.
.INPUTS
  None. You cannot pipe objects to Set-ServersInMaintenanceMode
.OUTPUTS
  None
#>
[CmdletBinding(DefaultParameterSetName="DefaultParameterSet",SupportsShouldProcess,ConfirmImpact="Low")]
param (
  [Parameter(Mandatory=$true,Position=0)]
  [Alias("Catalog","MC")]
  [string]$MachineCatalog,
  [Parameter(Mandatory=$true,ParameterSetName="count",Position=1)]
  [int16]$Count,
  [Parameter(Mandatory=$true,ParameterSetName="flip")]
  [switch]$Flip,
  [Parameter(Mandatory=$true,ParameterSetName="all",DontShow)]
  [switch]$All
)

begin {
  try {
    add-pssnapin $(Get-PSSnapin -Registered Citrix.Broker.Admin.V? -ErrorAction Stop | Select-Object -last 1 -ExpandProperty Name)
  }
  catch {
    Write-Host "Could not get the necessary PSSnapin. Are you running from a Delivery Controller (XDC) Server? Exiting..."
    exit 42
  }
}

process {
  $MachinesInCatalog = Get-BrokerMachine -CatalogName $MachineCatalog
  $MachineCount = $MachinesInCatalog.Count
  #[int]$MaintenanceModeCount = $($MachinesInCatalog | Where-Object -Property "InMaintenanceMode" -EQ $true).count
  $ErrorActionPreference = "Stop"
  switch ($psCmdlet.ParameterSetName) {
    "count" {
      $NumServersToMaint = $Count
      # If the absolute value of $NumServersToMaint is >= $MachineCount then there are two possibilities:

      if ([system.Math]::Abs($NumServersToMaint) -ge $MachineCount) {
        # 1. The user is trying to put more servers into Maintenance Mode than are in
        # the farm, and continuing will put the farm in an outage
        if ($NumServersToMaint -gt 0) {
          $PopupResponse = New-Popup -Title "WARNING: WILL TAKE DOWN $MachineCatalog" -Buttons AbortRetryIgnore -Icon Stop `
          -Message "This will put ALL $MachineCatalog servers in maintenance mode.
          THIS WILL PUT $MachineCatalog IN AN OUTAGE!
          If you want to enter a new number of servers to put into Maintenance Mode, select `"Retry`"
          To exit the script now, select `"Abort`"
          To proceed ahead and put ALL $MachineCatalog servers in maintenance mode select `"Ignore`""

          switch ($PopupResponse) {
            3 { # User chose "Abort"
              exit 12
            }
            4 { # User chose "Retry"
              $NumServersToMaint = Read-NumberInRange -Range $($MachineCount - 1)
              break
            }
            5 { # User chose "Ignore"
              $NumServersToMaint = $MachineCount
              break
            }
          }
        }

        # 2. The user is trying to keep more servers out of Maintenance Mode than are
        # in the farm, and continuing will result in zero servers in Maintenance
        elseif ($NumServersToMaint -le 0) {
          $PopupResponse = New-Popup -title "No Servers will enter Maintenance" -Buttons YesNo -Icon Question `
          -message "The current count value will result in Zero servers in maintenance mode.
          Do you want to enter a new number of servers to put into Maintenance Mode?"

          switch ($PopupResponse) {
            6 { # User chose "Yes"

              $NumServersToMaint = Read-NumberInRange -Range $($MachineCount - 1)
            }
            7 { # User chose "No"

              $NumServersToMaint = 0
            }
          }
        }
      }
      # If $NumServersToMaint is negative, then add $MachineCount to it.
      # This is the same as subtracting the absolute value of count from $MachineCount.
      if ($NumServersToMaint -lt 0) {
        $NumServersToMaint = $MachineCount + $NumServersToMaint
      }

    }
    "all" {
      $NumServersToMaint = $MachineCount
    }
    "flip" {
      $NumServersToMaint = $($MachinesInCatalog | Where-Object -Property "InMaintenanceMode" -EQ $false).count
      $MachinesInCatalog.foreach{
        $CurrentMachine = $_
        [bool]$FlippedValue = -not $CurrentMachine.InMaintenanceMode
        if ($FlippedValue) {
          Write-Output "Adding $($CurrentMachine.MachineName) to Maintenance Mode."
        }
        else{
          Write-Output "Removing $($CurrentMachine.MachineName) from Maintenance Mode."
        }
        $CurrentMachine.InMaintenanceMode = $FlippedValue
      }
    }
    "DefaultParameterSet" {
      $NumServersToMaint = $MachineCount / 2 # If the number of servers to put into Maintenance mode isn't provided, do 1/2 the farm.
    }
  }

  [int]$MaintenanceModeCount = $($MachinesInCatalog | Where-Object -Property "InMaintenanceMode" -EQ $true).count
  Write-Output "MaintenanceModeCount: $MaintenanceModeCount"
  if ($MaintenanceModeCount -gt $NumServersToMaint) {
    $ExtraMMServers = $MaintenanceModeCount - $NumServersToMaint
    $PopupResponse = New-Popup -title "Reduce the number of Maintenance Mode servers?"  -Buttons YesNo -Icon Question `
    -message "There are currently $MaintenanceModeCount servers in Maintenance Mode.
    Should $ExtraMMServers servers be removed to bring it down to $($NumServersToMaint)?"

    switch ($PopupResponse) {
      6 { # User chose "Yes"
        # User chose to reduce
        $($MachinesInCatalog | Where-Object -Property "InMaintenanceMode" -EQ $true | Select-Object -Last $ExtraMMServers).foreach{
          Write-Output "Removing $($_.MachineName) from Maintenance Mode."
          $_.InMaintenanceMode = $false

        }
        break
      }
      7 { # User chose "No"
        # User chose not to reduce
        break
      }
    }
  }
  elseif ($MaintenanceModeCount -lt $NumServersToMaint) {
    do {
      $CurrentMachine = $($MachinesInCatalog | Where-Object -Property "InMaintenanceMode" -EQ $false | Select-Object -First 1)
      $CurrentMachine.InMaintenanceMode = $true
      Write-Output "Adding $($CurrentMachine.MachineName) to Maintenance Mode."
    } until ($($MachinesInCatalog | Where-Object -Property "InMaintenanceMode" -EQ $true).count -eq $NumServersToMaint)
  }

  $MachinesInCatalog.foreach{
    $CurrentMachine = $_
    Set-BrokerMachineMaintenanceMode -InputObject $CurrentMachine -MaintenanceMode $CurrentMachine.InMaintenanceMode
  }

}
}
