---
external help file: MachineCatalogManager-help.xml
Module Name: MachineCatalogManager
online version: http://machinecatalogmanager.readthedocs.io/en/latest/functions/Set-ServersInMaintenanceMode.md
schema: 2.0.0
---

# Set-ServersInMaintenanceMode

## SYNOPSIS
Set servers in a given Machine Catalog into Maintenance Mode.

## SYNTAX

### DefaultParameterSet (Default)
```
Set-ServersInMaintenanceMode [-MachineCatalog] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### count
```
Set-ServersInMaintenanceMode [-MachineCatalog] <String> [-Count] <Int16> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### flip
```
Set-ServersInMaintenanceMode [-MachineCatalog] <String> [-Flip] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### all
```
Set-ServersInMaintenanceMode [-MachineCatalog] <String> [-All] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Set servers in a given Machine Catalog (MC) into Maintenance Mode (MM).

## EXAMPLES

### EXAMPLE 1
```
Set-ServersInMaintenanceMode -MachineCatalog B289A_MC
```

Will set the default number of servers into Maintenance Mode (currently one half of the number in the Catalog)

### EXAMPLE 2
```
Set-ServersInMaintenanceMode -MachineCatalog C289_MC -Count 4
```

Will put a specific number of servers (4 in this case) in Maintenance Mode

### EXAMPLE 3
```
Set-ServersInMaintenanceMode -MachineCatalog P289_MC -Count -3
```

Will keep a specific number of servers (3 in this case) out of Maintenance Mode, and put the rest into Maintenance Mode

### EXAMPLE 4
```
Set-ServersInMaintenanceMode -MachineCatalog B289A_MC -Flip
```

Will set any servers with Maintenance Mode On to Off, and all Off servers to On

### EXAMPLE 5
```
Set-ServersInMaintenanceMode -MachineCatalog T4298_MC -All
```

Will set all servers into Maintenance Mode without prompting the user to double check.

## PARAMETERS

### -MachineCatalog
The Machine Catalog you're working with, i.e "M4298_MC" or "C289_RevCycle_MC" This parameter is Mandatory.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Catalog, MC

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Count
The number of servers to put into Maintenance Mode (MM) (i.e.
5).
If negative (i.e.
-4) it will keep that many servers out of MM and add the rest.

```yaml
Type: Int16
Parameter Sets: count
Aliases:

Required: True
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Flip
Will flip the Maintenance Mode state (On to Off and vice versa) of all servers in the Machine Catalog

```yaml
Type: SwitchParameter
Parameter Sets: flip
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
Will specifically put ALL servers in the Machine Catalog into Maintenance Mode without the prompts to make sure.
USE WITH CAUTION!

```yaml
Type: SwitchParameter
Parameter Sets: all
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Set-ServersInMaintenanceMode
## OUTPUTS

### None
## NOTES

## RELATED LINKS

[http://machinecatalogmanager.readthedocs.io/en/latest/functions/Set-ServersInMaintenanceMode.md](http://machinecatalogmanager.readthedocs.io/en/latest/functions/Set-ServersInMaintenanceMode.md)

[https://github.com/Corey-Keller/MachineCatalogManager/blob/master/MachineCatalogManager/Public/Set-ServersInMaintenanceMode.ps1](https://github.com/Corey-Keller/MachineCatalogManager/blob/master/MachineCatalogManager/Public/Set-ServersInMaintenanceMode.ps1)

