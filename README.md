# PowerShell module for CapaInstaller #
### Requires [KristionW/CapaPosh](https://github.com/KristionW/CapaPosh)
Adds functionality to [KristionW/CapaPosh](https://github.com/KristionW/CapaPosh) specific to what i personally need and will most likely not be useful to most.
 
This is why im keeping this seperate
 
#### Functions
```
  Get-CapaUnitOld
  Get-CapaUnitBitlocker
```

 
#### Examples
##### Get-CapaUnitOld
```
  Get-CapaUnitOld -DaysSinceLastLogon 90 -ExportPath "C:\temp\export.csv"
```
This gets a list of computers that have not logged in to capa in the last 90 days and exports it to a CSV file. ExportPath is optional, if not specified the return will only be displayed in the console

##### Get-CapaUnitBitlocker
```
  Get-CapaUnitBitlocker -Unitname "PCName"
```
This returns the bitlocker key for the specified computer
