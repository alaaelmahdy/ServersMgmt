<#	
	=============================================================================
	 Created For: 	To Include All the functions Necessary for the systemMgmt DB
	 Created on:   	9/4/2019 6:52 PM
	 Created by:   	Alaa Elmahdy
	 Filename:     	SystemMgmtFunctions.psm1
	-------------------------------------------------------------------------
	 Module Name: SystemMgmtFunctions
	=============================================================================
#>

function Send-SMS
{
	#SMS Gateway Send Function	
}

function Get-Otp($SECRET, $LENGTH, $WINDOW)
{
	$enc = [System.Text.Encoding]::UTF8
	$hmac = New-Object -TypeName System.Security.Cryptography.HMACSHA1
	$hmac.key = Convert-HexToByteArray(Convert-Base32ToHex(($SECRET.ToUpper())))
	$timeBytes = Get-TimeByteArray $WINDOW
	$randHash = $hmac.ComputeHash($timeBytes)
	
	$offset = $randhash[($randHash.Length - 1)] -band 0xf
	$fullOTP = ($randhash[$offset] -band 0x7f) * [math]::pow(2, 24)
	$fullOTP += ($randHash[$offset + 1] -band 0xff) * [math]::pow(2, 16)
	$fullOTP += ($randHash[$offset + 2] -band 0xff) * [math]::pow(2, 8)
	$fullOTP += ($randHash[$offset + 3] -band 0xff)
	
	$modNumber = [math]::pow(10, $LENGTH)
	$otp = $fullOTP % $modNumber
	$otp = $otp.ToString("0" * $LENGTH)
	return $otp
}
function Get-TimeByteArray($WINDOW)
{
	$span = (New-TimeSpan -Start (Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0) -End (Get-Date).ToUniversalTime()).TotalSeconds
	$unixTime = [Convert]::ToInt64([Math]::Floor($span/$WINDOW))
	$byteArray = [BitConverter]::GetBytes($unixTime)
	[array]::Reverse($byteArray)
	return $byteArray
}
function Convert-HexToByteArray($hexString)
{
	$byteArray = $hexString -replace '^0x', '' -split "(?<=\G\w{2})(?=\w{2})" | %{ [Convert]::ToByte($_, 16) }
	return $byteArray
}
function Convert-Base32ToHex($base32)
{
	$base32chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
	$bits = "";
	$hex = "";
	
	for ($i = 0; $i -lt $base32.Length; $i++)
	{
		$val = $base32chars.IndexOf($base32.Chars($i));
		$binary = [Convert]::ToString($val, 2)
		$staticLen = 5
		$padder = '0'
		# Write-Host $binary
		$bits += Add-LeftPad $binary.ToString()  $staticLen  $padder
	}
	
	
	for ($i = 0; $i + 4 -le $bits.Length; $i += 4)
	{
		$chunk = $bits.Substring($i, 4)
		# Write-Host $chunk
		$intChunk = [Convert]::ToInt32($chunk, 2)
		$hexChunk = Convert-IntToHex($intChunk)
		# Write-Host $hexChunk
		$hex = $hex + $hexChunk
	}
	return $hex;
	
}
function Convert-IntToHex([int]$num)
{
	return ('{0:x}' -f $num)
}
function Add-LeftPad($str, $len, $pad)
{
	if (($len + 1) -ge $str.Length)
	{
		while (($len - 1) -ge $str.Length)
		{
			$str = ($pad + $str)
		}
	}
	return $str;
}
function Update-Servers ($user)
{
	$key = Get-RegKey $user
	if ($key -eq '1')
	{
		if ($Session:Privilege -eq "Admin")
		{
			$Servers = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.Servers"
		}
		elseif ($Session:Privilege -eq "User")
		{
			$DisplayName = (Get-aduser -identity $user -Properties displayName).displayName
			$servers = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.Servers" | where { $_.Owner -match $DisplayName }
		}
		Else
		{
			$Servers = $null
		}
	}
	return $Servers
}
function Update-PublishedServers ($user)
{
	$key = Get-RegKey $user
	if ($key -eq '1')
	{
		if ($Session:Privilege -eq "Admin")
		{
			$VlanLocations = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.VlanLocations"
			$PublicUrls = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.PublicUrls"
			$InternalUrls = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.InternalUrls"
			$ALLPublishedServers = @()
			$PublicUrls | foreach {
				$obj = [pscustomobject]@{
					ServerIP = $_.ServerIP
					Service  = $_.Service
					VIP	     = $_.VIP
					Port	 = $_.Port
					URL	     = $_.URL
					VIPType  = "PublicVIP"
					PublicIP = $_.PublicIP
					Availability = $_.Availability
					PublishingType = "Public"
				}
				$ALLPublishedServers += $obj
			}
			$InternalUrls | foreach {
				$obj = [pscustomobject]@{
					ServerIP = $_.ServerIP
					Service  = $_.Service
					VIP	     = $_.VIP
					Port	 = $_.Port
					URL	     = $_.URL
					VIPType  = "InternalVIP"
					PublicIP = "-"
					Availability = $_.Availability
					PublishingType = "Internal"
				}
				$ALLPublishedServers += $obj
			}
			
		}
		elseif ($Session:Privilege -eq "User")
		{
			$DisplayName = (Get-aduser -identity $user -Properties displayName).displayName
			$servers = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.Servers" | where { $_.Owner -match $DisplayName }
			$PublicUrls = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.PublicUrls" | where { $Servers.IPAddress -contains $_.ServerIP }
			$InternalUrls = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.InternalUrls" | where { $Servers.IPAddress -contains $_.ServerIP }
			$ALLPublishedServers = @()
			$PublicUrls | foreach {
				$obj = [pscustomobject]@{
					ServerIP = $_.ServerIP
					Service  = $_.Service
					VIP	     = $_.VIP
					Port	 = $_.Port
					URL	     = $_.URL
					VIPType  = "PublicVIP"
					PublicIP = $_.PublicIP
					Availability = $_.Availability
					PublishingType = "Public"
				}
				$ALLPublishedServers += $obj
			}
			$InternalUrls | foreach {
				$obj = [pscustomobject]@{
					ServerIP = $_.ServerIP
					Service  = $_.Service
					VIP	     = $_.VIP
					Port	 = $_.Port
					URL	     = $_.URL
					VIPType  = "InternalVIP"
					PublicIP = "-"
					Availability = $_.Availability
					PublishingType = "Internal"
				}
				$ALLPublishedServers += $obj
			}
			
		}
		Else
		{
			$ALLPublishedServers = $null
		}
	}
	return $ALLPublishedServers
}
function Update-VlanLocations ($user)
{
	$key = Get-RegKey $user
	if ($key -eq '1')
	{
		if ($Session:Privilege -eq "Admin")
		{
			$Servers = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.Servers"
			$VlanLocations = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.VlanLocations"
		}
		elseif ($Session:Privilege -eq "User")
		{
			$DisplayName = (Get-aduser -identity $user -Properties displayName).displayName
			$servers = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.Servers" | where { $_.Owner -match $DisplayName }
			$VlanLocations = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.VlanLocations" | where { $Servers.Vlan -contains $_.Vlan }
			
		}
		Else
		{
			$VlanLocations = $null
		}
	}
	return $VlanLocations
}
function Check-Privilege ($User)
{
	#Identify the User Privilege according to AD group Membership
	
	$Admins = Get-ADGroupMember -Identity "ServerDashboardAdmins" -Recursive | Select -ExpandProperty Name
	$Users = Get-ADGroupMember -Identity "ServerDashboardUsers" -Recursive | Select -ExpandProperty Name
	$DisplayName = (Get-aduser -Filter { sAMAccountName -eq $User } -Properties displayName | select Displayname).displayName
	$Privilege = $null
	if ($DisplayName -ne $null)
	{
		If ($Admins -contains $DisplayName)
		{
			$Privilege = "Admin"
		}
		elseif ($Users -contains $DisplayName)
		{
			$Privilege = "User"
		}
		Else
		{
			$Privilege = "None"
		}
		
	}
	Else
	{
		$Privilege = "None"
	}
	Return $Privilege
}
function Check-IsSysAdmin ($User)
{
	#Identify the User Privilege according to AD group Membership
	
	$SysAdmins = Get-ADGroupMember -Identity "IT-Systems-Managers" -Recursive | Select -ExpandProperty Name
	$DisplayName = (Get-aduser -Filter { sAMAccountName -eq $User } -Properties displayName | select Displayname).displayName
	[boolean]$Privilege = $false
	if ($DisplayName -ne $null)
	{
		If ($SysAdmins -contains $DisplayName)
		{
			$Privilege = $true
		}
		Else
		{
			$Privilege = $false
		}
		
	}
	Else
	{
		$Privilege = $false
	}
	Return $Privilege
}
function Check-RegKey ($User)
{
	if ($User -ne $null)
	{
		IF (-not (Test-Path -Path HKCU:\Software\ServersDashboard))
		{
			New-Item -Path HKCU:\Software -Name "ServersDashboard"
			Set-Item -Path HKCU:\Software\ServersDashboard -Value "Default Value"
		}
		
		IF (-not (Test-Path -Path HKCU:\Software\ServersDashboard\$User))
		{
			$Value = (Get-aduser -identity $User -Properties displayName).displayName
			New-Item -Path HKCU:\Software\ServersDashboard -Name "$User"
			Set-Item -Path HKCU:\Software\ServersDashboard\$User -Value $Value
		}
		New-ItemProperty -Path "HKCU:\Software\ServersDashboard\$User" -Name "LoginStatus" -Value "" -PropertyType "String" -ErrorAction SilentlyContinue
	}
}
function Set-RegKey ($user, $value)
{
	if ($User -ne $null)
	{
		set-ItemProperty -Path "HKCU:\Software\ServersDashboard\$User" -Name "LoginStatus" -Value $value
	}
}
function Get-RegKey ($user)
{
	if ($User -ne $null)
	{
		$value = (Get-ItemProperty -Path "HKCU:\Software\ServersDashboard\$User" -Name "LoginStatus").LoginStatus
		return $value
	}
}
Function Check-Null ($variable, $FinalValue = '""')
{
	[string]$ReturnVal = ""
	if ($variable -eq $null -or $variable -eq "null") { $ReturnVal = $FinalValue }
	else { $ReturnVal -eq "Required" }
	Return $ReturnVal
}
function Update-SRequests ($user)
{
	if ($Session:IsSysAdmin -eq $true)
	{
		$SRequests = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.ServerRequests" | where { $_.status -ne "1" }
	}
	Else
	{
		$DisplayName = (Get-aduser -identity $user -Properties displayName).displayName
		$SRequests = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "Select * from database01.dbo.ServerRequests" | where { $_.Owner -match $DisplayName -or $_.ProjectManager -match $DisplayName -or $_.Requester -match $DisplayName }
	}
	return $SRequests
}
function Identiy-CompName
{
	$Query = "select Domain from Database01.dbo.servers where IPAddress = '" + $CurrentServerIP + "'"
	$Domain = (Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "$Query").Domain
	switch ($Domain)
	{
		'WorkGroup' {
			$CompName = $Session:CurrentServerIP
		}
		'Domain.com' {
			$CompName = $Session:CurrentServerName
		}
	}
	return $CompName
}
Function Check-ServerState
{
	
	$ServerList = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "select * from database01.dbo.servers"
	foreach ($Server in $ServerList)
	{
		if (test-Connection -ComputerName $Server.ipaddress -Count 1 -Quiet)
		{
			$Query = "update database01.dbo.servers set ServerState = 'ON' where ipaddress = '" + $Server.ipaddress + "'"
			Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
		}
		Else
		{
			$Query = "update database01.dbo.servers set ServerState = 'OFF' where ipaddress = '" + $Server.ipaddress + "'"
			Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
			
		}
	}
}

