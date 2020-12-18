function Get-CapaUnitOld 
{
	#Needs an option to choose time scope
	[CmdletBinding()]
	param
	(
        [Parameter(Mandatory = $false)]
		[string]$ExportPath="",
		[Parameter(Mandatory = $false)]
		[int]$DaysSinceLastRun = 95
	)
	
	Begin
	{
		$FinalList = @()
        $Compare = (Get-Date).AddDays($DaysSinceLastRun * -1)
	}
	Process
	{
        $OldList = Get-CapaUnit -UnitType Computer | Where-Object {$_.UnitLastExecuted -lt $Compare} | Select-Object Unitname, UnitCreated, Unitlastexecuted
        foreach ($computer in $OldList) {
            try {
				$adcomputer = (Get-ADComputer $computer.Unitname -Properties LastLogonDate).LastLogonDate
            } 
            Catch{$adcomputer = $null}

			$CurrentUser = (Get-CapaUnitRelations -UnitName $computer.Unitname -UnitType Computer | Where-Object {$_.RelationType -like "Current User"}).Name
			$FinalList += [pscustomobject][ordered] @{
				Name = $computer.Unitname
				CurrentUser = $CurrentUser
				LastRunCapa = $computer.UnitLastExecuted
				LastLogonAD = $adcomputer
			}
		}
    }
    End
    {
        If ($ExportPath -ne "")
        {
            $FinalList | Export-CSV -path $ExportPath -Encoding UTF8 -Delimiter ";" -NoTypeInformation
        }
        return $FinalList
	}
}


function Get-CapaUnitBitLocker
{
	[CmdletBinding()]
	param
	(
        [Parameter(Mandatory = $false)]
		[string]$UnitName
	)
	
	Begin
	{
		$CapaCom = New-Object -ComObject CapaInstaller.SDK
		$CapaCustom = @()
	}
	Process
	{
		Get-CapaUnit -UnitType Computer | Where-Object {$_.UnitName -match $UnitName} | ForEach-Object -Process {
			$UnitNameL = $_.UnitName
			$Custom = $CapaCom.GetCustomInventoryForUnit("$UnitNameL", "Computer")
			$CustomList = $Custom -split "`r`n"
			
			$CustomList | ForEach-Object -Process {
				$SplitLine = ($_).split('|')
				
				Try
				{
					If ($Splitline[0] -match "Bitlocker") {
						$CapaCustom += [pscustomobject][ordered] @{
							UnitName = $UnitNameL
							BitlockerKey = $SplitLine[2]
						}
					}
				}
				Catch
				{
					Write-Warning -Message "An error occured for computer: $($SplitLine[0]) "
				}
			}
		}
	}
	End
	{
		Return $CapaCustom
		$CapaCom = $null
		Remove-Variable -Name CapaCom
	}
}