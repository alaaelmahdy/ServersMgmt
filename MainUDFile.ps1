#region Script Variables
$Root = "$PSScriptRoot\Files\"
$pages = @()
$EndpointInit = New-UDEndpointInitialization -Module @("ActiveDirectory", "SystemMgmtFunctions") -Variable Root, Pages

#endregion Script Variables

#region Content-Variables
$GridData = New-UDGrid -Id "Grid1" -Title "Servers Information" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Type", "Status", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Type", "Status", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Type	 = $_.Type
			Status   = if ($_.ServerState -eq "ON") { New-UDSwitch -OnText "ON" -OffText "OFF" -On } else { New-UDSwitch -OnText "ON" -OffText "OFF" }
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Servers-Information"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$BKBStatusGrid = New-UDGrid -Id "Grid2" -Title "Backup Information" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Type", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Type", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Type	 = $_.Type
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Backup-State"
				Invoke-UDRedirect -url "/ServerInfo"
			}
		}
	} | Out-UDGridData
}
$Tower1 = New-UDGrid -Id "Grid3" -Title "Tower1 Datacenter Server" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Type", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Type", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Location -eq "Tower1 Datacenter" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Type	 = $_.Type
			Backup   = $_.Backup
			Rack	 = $_.Rack
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Tower1-Datacenter"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$Tower1_DC_RackView = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ServCollection = $Servers | where{ $_.Location -eq "Tower1 Datacenter" -and $_.type -eq "Physical Server" }
	$results = $ServCollection | Group-Object Rack | Sort-Object @{ e = { $_.Name -as [int] } }
	foreach ($result in $results)
	{
		if ($result.Name -eq "-") { $RackName = "Servers With No Rack Information:" }
		Else { $RackName = "Rack No: $($result.Name)" }
		
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$RackName" -Content {
				New-UDGrid -Id "$RackName Viw" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner") -Endpoint {
					$FinalResult = @()
					foreach ($Rsrv in $result.group)
					{
						$obj = [PSCustomObject]@{
							Asset_ID = $Rsrv.Asset_ID
							Name	 = $Rsrv.Name
							IPAddress = $Rsrv.IPAddress
							OperatingSystem = $Rsrv.OperatingSystem
							Owner    = $Rsrv.Owner
						}
						$FinalResult += $obj
					}$FinalResult | Out-UDGridData
				}
			}
		}
	}
}
$Tower2_DC_RackView = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ServCollection = $Servers | where{ $_.Location -eq "Tower2 Datacenter" -and $_.type -eq "Physical Server" }
	$results = $ServCollection | Group-Object Rack | Sort-Object @{ e = { $_.Name -as [int] } }
	foreach ($result in $results)
	{
		if ($result.Name -eq "-") { $RackName = "Servers With No Rack Information:" }
		Else { $RackName = "Rack No: $($result.Name)" }
		
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$RackName" -Content {
				New-UDGrid -Id "$RackName Viw" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner") -Endpoint {
					$FinalResult = @()
					foreach ($Rsrv in $result.group)
					{
						$obj = [PSCustomObject]@{
							Asset_ID = $Rsrv.Asset_ID
							Name	 = $Rsrv.Name
							IPAddress = $Rsrv.IPAddress
							OperatingSystem = $Rsrv.OperatingSystem
							Owner    = $Rsrv.Owner
						}
						$FinalResult += $obj
					}$FinalResult | Out-UDGridData
				}
			}
		}
	}
}
$Tower2Grid = New-UDGrid -Id "Grid4" -Title "Tower2 Datacenter Server" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Type", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Type", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Location -eq "Tower2 Datacenter" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Type	 = $_.Type
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Tower2-Datacenter"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$Tower3Grid = New-UDGrid -Id "Grid5" -Title "Tower3 Datacenter Server" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Type", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Type", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Location -eq "Tower3 Datacenter" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Type	 = $_.Type
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Tower3-Datacenter"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$VMSGrid = New-UDGrid -Id "Grid6" -Title "Virtual Servers" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Type -eq "Virtual Machine" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Virtual-Servers"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$HypervGrid = New-UDGrid -Id "Grid61" -Title "Virtual Servers" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Type -eq "Virtual Machine" -and $_.Hypervisor -eq "Hyperv" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/HypervGrid"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$VmwareGrid = New-UDGrid -Id "Grid611" -Title "Virtual Servers" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Type -eq "Virtual Machine" -and $_.Hypervisor -eq "Vmware" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/VmwareGrid"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$OVMGrid = New-UDGrid -Id "Grid6111" -Title "Virtual Servers" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Type -eq "Virtual Machine" -and $_.Hypervisor -eq "OVM" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/OVMGrid"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$PServersGrid = New-UDGrid -Id "Grid7" -Title "Physical Servers" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State", "Server Info") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup", "ServerInfo") -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$Servers | where{ $_.Type -eq "Physical Server" } | foreach{
		[PSCustomObject]@{
			Asset_ID = $_.Asset_ID
			Name	 = $_.Name
			IPAddress = $_.IPAddress
			OperatingSystem = $_.OperatingSystem
			Owner    = $_.Owner
			Backup   = $_.Backup
			ServerInfo = New-UDButton -Text "Server Info" -OnClick {
				
				$Session:CurrentServerName = $_.Name
				$Session:CurrentServerIP = $_.IPAddress
				$Session:ReturnURL = "/Physical-Servers"
				Invoke-UDRedirect -url "/ServerInfo"
			}
			
		}
	} | Out-UDGridData
}
$Vlan_All = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$VlanLocations = Update-VlanLocations $Session:LoggedInUser
	$vlans = $Servers.Vlan | select -Unique
	ForEach ($vlan in $vlans)
	{
		$vlanLocation = ($VlanLocations | where{ $_.Vlan -eq $vlan }).VlanLocation
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$vlan Servers" -Content {
				New-UDGrid -Id "$($vlan)_AGrid" -Title "Vlan Description: $vlanLocation" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup") -Endpoint {
					$Servers | where { $_.Vlan -eq $vlan } | Out-UDGridData
				}
			}
		}
	}
}
$VLan_Tower2 = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$VlanLocations = Update-VlanLocations $Session:LoggedInUser
	$HFilter = $Servers | ?{ $_.location -eq "Tower2 Datacenter" }
	$vlans = $HFilter.Vlan | select -Unique
	ForEach ($vlan in $vlans)
	{
		$vlanLocation = ($VlanLocations | where{ $_.Vlan -eq $vlan }).VlanLocation
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$vlan Servers" -Content {
				New-UDGrid -Id "$($vlan)_HGrid" -Title "Vlan Description: $vlanLocation" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup") -Endpoint {
					$Servers | where { $_.Vlan -eq $vlan -and $_.location -eq "Tower2 Datacenter" } | Out-UDGridData
				}
			}
		}
	}
}
$VLan_Tower1 = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$FFilter = $Servers | ?{ $_.location -eq "Tower1 Datacenter" }
	$vlans = $FFilter.Vlan | select -Unique
	ForEach ($vlan in $vlans)
	{
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$vlan Servers" -Content {
				New-UDGrid -Id "$($vlan)_FGrid" -Title "" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup") -Endpoint {
					$Servers | where { $_.Vlan -eq $vlan -and $_.location -eq "Tower1 Datacenter" } | Out-UDGridData
				}
			}
		}
	}
}
$VLan_Tower3 = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$JFilter = $Servers | ?{ $_.location -eq "Tower3 Datacenter" }
	$vlans = $JFilter.Vlan | select -Unique
	ForEach ($vlan in $vlans)
	{
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$vlan Servers" -Content {
				New-UDGrid -Id "$($vlan)_JGrid" -Title "" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset ID", "Name", "IP Address", "Operating System", "Owner", "Backup State") -Properties ("Asset_ID", "Name", "IPAddress", "OperatingSystem", "Owner", "Backup") -Endpoint {
					$Servers | where { $_.Vlan -eq $vlan -and $_.location -eq "Tower3 Datacenter" } | Out-UDGridData
				}
			}
		}
	}
}
$VLans_Table = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$VlanLocations = Update-VlanLocations $Session:LoggedInUser
	$vlocs = $VlanLocations.type | where { $_ -ne "-" } | select -Unique
	ForEach ($vloc in $vlocs)
	{
		New-UDColumn -LargeSize 12 -Content {
			New-UDCard -Title "$vloc Networks" -Content {
				New-UDGrid -Id "$($vloc)_vlGrid" -Title "" -DefaultSortColumn "vlan" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Vlan Location", "Start IP", "End IP", "VLAN IP", "GateWay") -Properties ("VlanLocation", "Realstart", "Realend", "Vlan", "GateWay") -Endpoint {
					$VlanLocations | where { $_.type -eq $vloc } | Out-UDGridData
				}
			}
		}
	}
}
$ALL_Published_Servers = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$results = $ALLPublishedServers | Group-Object PublishingType
	foreach ($result in $results)
	{
		New-UDCard -Title "$($result.Name) Published Servers" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$F5_DMZ_VIPS = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{ $_.VIPType -eq "PublicVIP" -and $_.VIP -ne "-" }
	$results = $F5DMZVIPS | Group-Object VIP, URL
	foreach ($result in $results)
	{
		
		#New-UDColumn -LargeSize 12 -Content {
		
		New-UDCard -Title "VIP: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "URL: $($result.Name.split(",")[1])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
		#}
		
	}
}
$F5_Internal_VIPS = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{ $_.VIPType -eq "InternalVIP" -and $_.VIP -ne "-" }
	$results = $F5DMZVIPS | Group-Object VIP, URL
	foreach ($result in $results)
	{
		New-UDCard -Title "VIP: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "URL: $($result.Name.split(",")[1])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$LB_Internal_URLs = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{ $_.VIPType -eq "InternalVIP" }
	$results = $F5DMZVIPS | Group-Object URL, VIP
	foreach ($result in $results)
	{
		New-UDCard -Title "URL: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "VIP: $($result.Name.split(",")[1])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					IF ($Rsrv.VIP -eq "-") { $Rsrv.VIP = "Published As Single Node" }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$All_Public_URLs = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{ $_.PublishingType -eq "Public" }
	$results = $F5DMZVIPS | Group-Object URL, VIP
	foreach ($result in $results)
	{
		New-UDCard -Title "URL: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "VIP: $($result.Name.split(",")[1])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					IF ($Rsrv.VIP -eq "-") { $Rsrv.VIP = "Published As Single Node" }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$Public_IPs = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{ $_.PublishingType -eq "Public" }
	$results = $F5DMZVIPS | Group-Object PublicIP, URL, VIP
	foreach ($result in $results)
	{
		New-UDCard -Title "Public IP: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "URL: $($result.Name.split(",")[1]) VIP: $($result.Name.split(",")[2])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					IF ($Rsrv.VIP -eq "-") { $Rsrv.VIP = "Published As Single Node" }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$HA_Public_URLs = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{
		$_.PublishingType -eq "Public" -and $_.vip -ne "-"
	}
	$results = $F5DMZVIPS | Group-Object URL, VIP, PublicIP
	foreach ($result in $results)
	{
		New-UDCard -Title "URL: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "VIP: $($result.Name.split(",")[1]) Public IP: $($result.Name.split(",")[2])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					IF ($Rsrv.VIP -eq "-") { $Rsrv.VIP = "Published As Single Node" }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$Single_Public_URLs = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{
		$_.PublishingType -eq "Public" -and $_.vip -eq "-"
	}
	$results = $F5DMZVIPS | Group-Object URL, PublicIP
	foreach ($result in $results)
	{
		New-UDCard -Title "URL: $($result.Name.split(",")[0])" -Content {
			New-UDGrid -Id "$($result.Name)Servers" -Title "Public IP: $($result.Name.split(",")[1])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					IF ($Rsrv.VIP -eq "-") { $Rsrv.VIP = "Published As Single Node" }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$Published_Servers = New-UDRow -Endpoint {
	$Servers = Update-Servers $Session:LoggedInUser
	$ALLPublishedServers = Update-PublishedServers $Session:LoggedInUser
	$F5DMZVIPS = $ALLPublishedServers | where{ $_.PublishingType -eq "Public" }
	$results = $F5DMZVIPS | Group-Object URL, VIP, PublicIP
	foreach ($result in $results)
	{
		New-UDCard -Title "URL: $($result.Name.split(",")[0])" -Content {
			if ($($result.Name.split(",")[1])) { $vip = "Published As Single Node" }
			Else { $vip = $($result.Name.split(",")[1]) }
			New-UDGrid -Id "$($result.Name)Servers" -Title "VIP : $vip  Public IP: $($result.Name.split(",")[1])" -DefaultSortColumn "Asset_ID" -PageSize 100 -FilterText "Enter any thing to search for" -Headers ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Properties ("Asset_ID", "Name", "ServerIP", "Type", "Owner", "Service", "VIPType", "VIP", "Port", "URL", "PublicIP") -Endpoint {
				$FinalResult = @()
				foreach ($Rsrv in $result.group)
				{
					$SrvName = $Servers | where { $_.IPAddress -eq $Rsrv.ServerIP }
					IF ($Rsrv.VIP -eq "-") { $Rsrv.VIP = "Published As Single Node" }
					$obj = [PSCustomObject]@{
						Asset_ID = $SrvName.Asset_ID
						Name	 = $SrvName.Name
						ServerIP = $Rsrv.ServerIP
						Type	 = $SrvName.Type
						Owner    = $SrvName.Owner
						Service  = $Rsrv.Service
						VIPType  = $Rsrv.VIPType
						VIP	     = $Rsrv.VIP
						Port	 = $Rsrv.Port
						URL	     = $Rsrv.URL
						PublicIP = $Rsrv.PublicIP
					}
					$FinalResult += $obj
				}
				$FinalResult | Out-UDGridData
			}
		}
	}
}
$ServerInfo = New-UDRow -Endpoint {
	$Query = "select Domain from Database01.dbo.servers where IPAddress = '" + $Session:CurrentServerIP + "'"
	$Domain = (Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query "$Query").Domain
	switch ($Domain)
	{
		'WorkGroup' {
			#Return Button#
			New-UDRow -Endpoint {
				New-UDColumn -Size 3 -Content {
					New-UDButton -IconAlignment left -Text "Back" -Icon Home -OnClick { Invoke-UDRedirect -Url "$Session:ReturnURL" }
				}
				New-UDColumn -Size 3 -Content { }
				New-UDColumn -Size 3 -Content { }
				New-UDColumn -Size 3 -Content { }
			}
			#Collapsible
			New-UDCollapsible -Items {
				New-UDCollapsibleItem -Title "Server Name : $Session:CurrentServerName, Server IPAddress : $Session:CurrentServerIP" -Icon Info_circle -Content {
					New-UDRow -Endpoint {
						#Server Information Collection 
						$HWinfoQ = "select * from Database01.dbo.ServersHWinfo where ComputerIP = '" + $Session:CurrentServerIP + "'"
						$HWinfo = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $HWinfoQ
						$DiskinfoQ = "select * from Database01.dbo.ServersDisks where ComputerIP = '" + $Session:CurrentServerIP + "'"
						$Diskinfo = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $DiskinfoQ
						$SRVInfQ = "select * from Database01.dbo.Servers where IPAddress = '" + $Session:CurrentServerIP + "'"
						$SRVInf = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $SRVInfQ
						#ServerInfo Table
						New-UDColumn -Size 6 -Content {
							New-UDTable -Title "Server Information" -Style bordered -BackgroundColor '#F2F2F2' -Headers @(" ", " ") -Endpoint {
								@{
									'ComputerName' = $HWinfo.ComputerName
									'OSName'	   = $HWinfo.OSName
									'OSInstallDate' = $HWinfo.OSInstallDate
									'OSServicePackMajorVersion' = $HWinfo.OSServicePackMajorVersion
									'OSArchitecture' = $HWinfo.OSArchitecture
									'OSBuildNumber' = $HWinfo.OSBuildNumber
									'Manufacturer' = $HWinfo.Manufacturer
									'Model'	       = $HWinfo.Model
									'SerialNumber' = $HWinfo.SerialNumber
									'BiosName'	   = $HWinfo.BiosName
									'BiosVersion'  = $HWinfo.BiosVersion
									'MemorySize'   = $HWinfo.MemorySize
									'CPUName'	   = $HWinfo.CPUName
									'TotalCPUCores' = $HWinfo.TotalCPUCores
									'PercentFreeMemory' = $HWinfo.PercentFreeMemory
									'PercentCPUAvgLoad' = $HWinfo.PercentCPUAvgLoad
								}.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
							}
							#Disks Table
						}
						New-UDColumn -Size 6 -Content {
							New-UDTable -Style bordered -BackgroundColor '#F2F2F2' -Title "" -Headers ("Drive", "Vol.Name", "Size/GB", "Free/GB", "%Free") -Endpoint {
								$Diskinfo | foreach {
									[PSCustomObject]@{
										DeviceID = $_.DeviceID
										VolumeName = $_.VolumeName
										DiskSizeGB = $_.DiskSizeGB
										DiskFreeSpaceGB = $_.DiskFreeSpaceGB
										PercentFreeDiskSpace = $_.PercentFreeDiskSpace
									}
								} | Out-UDTableData -Property ("DeviceID", "VolumeName", "DiskSizeGB", "DiskFreeSpaceGB", "PercentFreeDiskSpace")
							}
							New-UDTable -Title " " -Style bordered -BackgroundColor '#F2F2F2' -Headers @(" ", " ") -Endpoint {
								@{
									'Asset_ID' = $SRVInf.Asset_ID
									'Vlan'	   = $SRVInf.Vlan
									'Owner'    = $SRVInf.Owner
									'Type'	   = $SRVInf.Type
									'HyperVisor' = $SRVInf.HyperVisor
									'Rack'	   = $SRVInf.Rack
									'Location' = $SRVInf.Location
									'Domain'   = $SRVInf.Domain
									'Backup'   = $SRVInf.Backup
									'ProjectManager' = $SRVInf.ProjectManager
									'Projects' = $SRVInf.Projects
									'Service'  = $SRVInf.Service
									'Function' = $SRVInf.Function
								}.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
								
							}
						}
					}
					
				}
				New-UDCollapsibleItem -Title "Server Status" -Active -Icon arrow_circle_right -Content {
					New-UdRow {
						#Automatic Services
						New-UdColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Automatic Services" -TextSize Medium -Endpoint {
								$SVCs = Get-Service -ComputerName $Session:CurrentServerIP | where { $_.StartType -eq "Automatic" -and $_.Status -eq "Stopped" }
								$SVCCT = $SVCs.count
								$SVCTXT = "$SVCCT Stopped Services"
								New-UDButton -Text $SVCTXT -Icon stop_circle -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Automatic And Stopped Services" -NoPaging -NoFilter -NoExport -Headers @(
											"Name", "Display Name", "Status") -Properties @("Name", "DisplayName", "Status") -Endpoint {
											$SVCs | foreach{
												[pscustomobject]@{
													Name = $_.Name
													DisplayName = $_.DisplayName
													Status = $_.Status
												}
												
											} | Out-UDGridData
										}
									}
								}
							}
						}
						#Antivirus Status
						New-UDColumn -Size 1.5 -Endpoint {
							
							New-UDCard -Title "Antivirus Status" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.AVState where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$AVResult = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$AVTitle = if ($AVResult.IsUpdated -eq "Yes") { "Installed & Updated" }
								else { "Needs Attention" }
								New-UDButton -Text $AVTitle -Icon shield_alt -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Antivirus Details" -NoPaging -NoFilter -NoExport -Headers @("IsInstalled", "SEPVersion", "IsUpdated", "LastUpdated", "State") -Properties @("IsInstalled", "SEPVersion", "IsUpdated", "LastUpdated", "State") -Endpoint {
											$AVResult | foreach {
												[pscustomobject]@{
													IsInstalled = $_.IsInstalled
													SEPVersion  = $_.SEPVersion
													IsUpdated   = $_.IsUpdated
													LastUpdated = $_.LastUpdated
													State	    = $_.State
												}
											} | Out-UDGridData
										}
									}
								}
							}
						}
						#FireWall Status
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "FireWall Status" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.FWState where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$FWResult = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$FWTitle = if ($FWResult.DomainProfile -eq "ON") { "FireWall Is ON" }
								else { "Needs Attention" }
								New-UDButton -Text $FWTitle -Icon cloud_upload_alt -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "FireWall Details" -NoPaging -NoFilter -NoExport -Headers @("DomainProfile", "PrivateProfile", "PublicProfile") -Properties @("DomainProfile", "PrivateProfile", "PublicProfile") -Endpoint {
											$FWResult | select DomainProfile, PrivateProfile, PublicProfile | Out-UDGridData
										}
									}
								}
							}
						}
						#Internet Connection
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Internet Connection" -TextSize Medium -Endpoint {
								$Query = "select IsConnected from Database01.dbo.IsInternetConnected where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$IsConnected = (Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query).IsConnected
								$INTTitle = if ($IsConnected -eq "True") { "Connected" }
								else { "Disconnected" }
								New-UDButton -Text $INTTitle -Icon wifi -IconAlignment left
							}
						}
						#Windows Roles
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Windows Roles" -TextSize Medium -Endpoint {
								$Query = "select RoleName from Database01.dbo.WindowsRoles where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$RoleNames = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$RTitle = if ($RoleNames.count -gt 0) { "$($RoleNames.count) Installed" }
								else { "NO Roles Detected" }
								New-UDButton -Text $RTitle -Icon r_project -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Installed Windows Roles" -NoPaging -NoFilter -NoExport -Headers @("RoleName") -Properties @("RoleName") -Endpoint {
											$RoleNames | select RoleName | Out-UDGridData
										}
									}
								}
							}
						}
						#File Shares
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "File Shares" -TextSize Medium -Endpoint {
								$Query = "select ShareName,SharePath,ShareDesc from Database01.dbo.FileShares where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Shares = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$STitle = if (($Shares.ShareName).count -gt 0) { "$(($Shares.ShareName).count) Shares" }
								else { "NO Shared Folders" }
								New-UDButton -Text $STitle -Icon folder -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Shared Folders Information" -NoPaging -NoFilter -NoExport -Headers @("ShareName", "SharePath", "ShareDesc") -Properties @("ShareName", "SharePath", "ShareDesc") -Endpoint {
											$Shares | select ShareName, SharePath, ShareDesc | Out-UDGridData
										}
									}
								}
							}
						}
					}
					New-UDRow {
						#Windows UPTime
						New-UdColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Windows UPTime" -TextSize Medium -Endpoint {
								$Lastreboottime = Get-WmiObject -ComputerName $Session:CurrentServerIP Win32_OperatingSystem | select @{ LABEL = 'LastBootUpTime'; EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } }
								$Uptime = (get-date) - ($Lastreboottime).LastBootUpTime
								$UptimeTitle = "$([math]::Round($($Uptime.TotalHours), 2)) Hours"
								New-UDButton -Text $UptimeTitle -Icon clock -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "UpTime History" -NoPaging -NoFilter -NoExport -Headers @("Startup", "Shutdown", "Uptime /Days", "Uptime /HRs") -Properties @("UStartup", "UShutdown", "UptimeDays", "UptimeHRs") -Endpoint {
											$Uptimes = @()
											$filterHt = @{
												'LogName' = 'System'
												'ID'	  = 6005
											}
											$StartEvents = Get-WinEvent -ComputerName $Session:CurrentServerIP -FilterHashtable $filterHt
											$StartTimes = $StartEvents.TimeCreated
											
											## Find all stop events
											$filterHt.ID = 6006
											$StopEvents = Get-WinEvent -ComputerName $Session:CurrentServerIP -FilterHashtable $filterHt -Oldest
											$StopTimes = $StopEvents.TimeCreated
											
											foreach ($startTime in $StartTimes)
											{
												$StopTime = $StopTimes | ? { $_ -gt $StartTime } | select -First 1
												if (-not $StopTime)
												{
													$StopTime = Get-Date
												}
												$output = [ordered]@{
													'UStartup'   = $StartTime
													'UShutdown'  = $StopTime
													'UptimeDays' = [math]::Round((New-TimeSpan -Start $StartTime -End $StopTime).TotalDays, 2)
													'UptimeHRs'  = [math]::Round((New-TimeSpan -Start $StartTime -End $StopTime).TotalHours, 2)
												}
												
												$Uptimes += [pscustomobject]$output
											}
											$UpTimes | Out-UDGridData
										}
									}
								}
							}
						}
						#.Net FrameWork
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title ".Net FrameWork" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.DotNetVersions where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$DotNetVersions = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$MajorNetVersion = $DotNetVersions | Where { $_.NETFramework -eq "Full" }
								$NTitle = if ($($MajorNetVersion.Version).count -gt 0) { ".Net $($MajorNetVersion.Version)" }
								else { ".Net Not Detected" }
								New-UDButton -Text $NTitle -Icon project_diagram -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Installed .Net FrameWork" -NoPaging -NoFilter -NoExport -Headers @("NETFramework", "Product", "Version", "Release") -Properties @("NETFramework", "Product", "Version", "Release") -Endpoint {
											$DotNetVersions | select NETFramework, Product, Version, Release | Out-UDGridData
										}
									}
								}
							}
						}
						#Pending Reboot
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Pending Reboot" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.PendingReboot where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$PendingReboot = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$IsPendingReboot = $PendingReboot.IsRebootPending
								$RTitle = if ($($PendingReboot.IsRebootPending) -eq "True") { "Reboot is Required" }
								else { "No Reboot Required" }
								New-UDButton -Text $RTitle -Icon power_off -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Pending Reboot Details" -NoPaging -NoFilter -NoExport -Headers @("ComponentBasedServicing", "PendingComputerRenameDomainJoin", "WindowsUpdateAutoUpdate", "IsRebootPending") -Properties @("ComponentBasedServicing", "PendingComputerRenameDomainJoin", "WindowsUpdateAutoUpdate", "IsRebootPending") -Endpoint {
											$PendingReboot | select ComponentBasedServicing, PendingComputerRenameDomainJoin, WindowsUpdateAutoUpdate, IsRebootPending | Out-UDGridData
										}
									}
								}
							}
						}
						#PSversion
						New-UdColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Powershell Version" -TextSize Medium -Endpoint {
								$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
								$PSversionMajor = Invoke-Command -SessionOption $sessionOption -Credential (Get-StoredCredential -Name WCRED) -UseSSL -ComputerName $Session:CurrentServerIP -ErrorAction SilentlyContinue -ScriptBlock { return $PSVersionTable.PSVersion.Major }
								$PSTitle = "Powershell V.$PSversionMajor"
								
								New-UDButton -Text $PSTitle -Icon clock -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UDGrid -Title "Powershell Version Table" -NoPaging -NoFilter -NoExport -Headers @("Major", "Minor", "Build", "Revision") -Properties @("Major", "Minor", "Build", "Revision") -Endpoint {
											$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
											$PSversionT = Invoke-Command -SessionOption $sessionOption -Credential (Get-StoredCredential -Name WCRED) -UseSSL -ComputerName $Session:CurrentServerIP -ErrorAction SilentlyContinue -ScriptBlock { return $PSVersionTable.PSVersion }
											$PSversionT | Out-UDGridData
										}
									}
								}
							}
						}
						#Errors-Warning
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "EventLog Errors" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.ServerLogs where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Logs = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$SystemLogs = $Logs | where { $_.logname -eq "system" }
								$APPLogs = $Logs | where { $_.logname -eq "Application" }
								$NTitle = if ($($Logs.count) -gt 0) { "$($Logs.count) Errors" }
								else { "No Errors Found" }
								New-UDButton -Text $NTitle -Icon exclamation_triangle -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Systems Event Log Errors and Warnings" -NoPaging -NoFilter -NoExport -Headers @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Properties @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Endpoint {
											$SystemLogs | select LogCount, LogID, LogType, LogFirstLogged, LogLastLogged, LogMSG | Out-UDGridData
										}
										New-UdGrid -Title "Applications Event Log Errors and Warnings" -NoPaging -NoFilter -NoExport -Headers @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Properties @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Endpoint {
											$APPLogs | select LogCount, LogID, LogType, LogFirstLogged, LogLastLogged, LogMSG | Out-UDGridData
										}
									}
								}
							}
						}
						#Latest Updates
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Installed Updates" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.InstalledUpdates where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Updates = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$NTitle = if ($($Updates.count) -gt 0) { "$($Updates.count)Installed" }
								else { "0 Installed" }
								New-UDButton -Text "Installed" -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Latest Installed Updates" -NoPaging -NoFilter -NoExport -Headers @("Description", "HotFixID", "InstalledBy", "InstalledOn", "KBArticle") -Properties @("Description", "HotFixID", "InstalledBy", "InstalledOn", "KBArticle") -Endpoint {
											$Updates | select Description, HotFixID, InstalledBy, InstalledOn, KBArticle | Out-UDGridData
										}
									}
								}
								$Query1 = "select * from Database01.dbo.requiredUpdates where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Updates1 = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query1
								$NTitle1 = if ($($Updates1.count) -gt 0) { "$($Updates1.count)Required" }
								else { "0 Required" }
								New-UDButton -Text "Required" -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Required Updates" -NoPaging -NoFilter -NoExport -Headers @("Title", "KBID", "IsBeta", "IsDownloaded", "RebootRequired", "KBarticle") -Properties @("Title", "KBID", "IsBeta", "IsDownloaded", "RebootRequired", "KBarticle") -Endpoint {
											$Updates1 | select Title, KBID, IsBeta, IsDownloaded, RebootRequired, KBarticle | Out-UDGridData
										}
									}
								}
							}
						}
					}
				}
				New-UDCollapsibleItem -Title "Live Performance Counters:" -Icon chart_line -Content {
					#Charts
					New-UDCard -RevealTitle "Performance Counters" -Endpoint {
						New-UDRow -Endpoint {
							New-UDColumn -Size 4 -Content {
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (% disk time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											#Invoke-Command -Session $Session:CRTPSsession -ScriptBlock {}
											Get-Counter -ComputerName $Session:CurrentServerIP '\physicaldisk(_total)\% disk time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (Current disk queue length)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\physicaldisk(_total)\current disk queue length' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "CPU (% processor time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
							}
							New-UDColumn -Size 4 -Endpoint {
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (Avg. Disk sec/Read)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\physicaldisk(_total)\avg. disk sec/read' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "Memory (Available Mbytes)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#8028E842' -ChartBorderColor '#FF28E842' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP 'Memory\Available Mbytes' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "CPU (% Privileged time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\Processor(_Total)\% Privileged time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								
							}
							New-UDColumn -Size 4 -Endpoint {
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (Avg. Disk sec/Write)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\physicaldisk(_total)\avg. disk sec/write' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "Memory (Pages/sec)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#8028E842' -ChartBorderColor '#FF28E842' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\Memory\Pages/sec' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "CPU (% User time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerIP '\Processor(_Total)\% User time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
							}
						}
					}
					
				}
				New-UDCollapsibleItem -Title "Guide Lines For using Performance Counters:" -Icon arrow_circle_right -Content {
					New-UDCard -Content {
						New-UDHtml -Markup @'
<!DOCTYPE html>
<html>
<head>
<style>
div, dl, dt, dd, ul, ol, li, h1, h2, h3, h4, h5, h6, pre, form, p, blockquote, th, td {
    margin: 0;
    padding: 0;
}

body {
    background: #fff;
    color: #222;
    cursor: auto;
    font-family: "Helvetica Neue", Helvetica, Roboto, Arial, sans-serif;
    font-style: normal;
    font-weight: normal;
    line-height: 1.5;
    margin: 0;
    padding: 0;
    position: relative;
}
p {
    font-family: inherit;
    font-size: 1rem;
    font-weight: normal;
    line-height: 1.6;
    margin-bottom: 1.25rem;
    text-rendering: optimizeLegibility;
}
h4 {
    font-size: 1.15rem;
    color: rgb(0, 77, 113);;
}
h1, h2, h3, h4, h5, h6 {
    color: rgb(0, 77, 113);;
    font-family: "Helvetica Neue", Helvetica, Roboto, Arial, sans-serif;
    font-style: normal;
    font-weight: bold;
    line-height: 1.4;
    margin-bottom: 0.5rem;
    margin-top: 0.2rem;
    text-rendering: optimizeLegibility;
}
</style>
</head>
<body>


<h4>Overview</h4>
<p>When it comes to deciding what to monitor in regards to general server health 
I like to break it down into the following areas: Processor Utilization, Disk Activity, 
Memory Usage . The following set of counters will give you 
a good indication of any issues that could be affecting any of these areas.</p>
<h4>[Processor] "% Processor time"</h4>
<p>This is the percentage of total elapsed time that the processor was busy executing.&nbsp; 
This counter provides a very general measure of how busy the processor is and
<strong>if this counter is constantly high, say above 90%, then you'll need
			to use other counters </strong>(described below) in order to further determine the
			root cause of the CPU pressure.</p>
			<h4>[Processor] "% Privileged time"</h4>
			<p>This measures the percentage of elapsed time the processor spent executing in
			kernel mode.&nbsp; Since this counter takes into account only kernel operations
			(eg. memory management) a high percentage of privileged time, anything consistently
			<strong>above 25%, can usually point to a driver or hardware issue and should be
			investigated.&nbsp; </strong></p>
			<h4>[Processor] "% User time"</h4>
			<p>The percentage of elapsed time the processor spent executing in user mode.&nbsp;
			To describe this simply, it's really the amount of time the processor spent 
executing any user application code.; Generally, even on a dedicated SQL Server, 
I like this number to be consistently <strong>below 65%</strong> as you want to 
have some buffer for both the kernel operations mentioned above as well as any other 
bursts of CPU required by other applications. Anything consistently over 65% 
should be investigated and this might mean digging deeper into exactly what process 
is using the CPU (if it's not SQL Server) by using the "[Process] % User
									time" counter for the individual processes.</p>
		<h4>[Physical Disk] "Current Disk Queue Length" &amp; "Avg. Disk
									Queue Length"</h4>
		<p>The "Current Disk Queue Length" a direct measurement of the disk queue
		length at the time it is sampled so in most cases it is better to monitor "Avg.
									Disk Queue Length" as this value is derived using the (Disk Transfers/sec)*(Disk
			sec/Transfer) counters.&nbsp; Using this calculation gives a much better measure
		of the disk queue over time, smoothing out any quick spikes.&nbsp; Having any physical
		disk with an average <strong>queue length over 2 for prolonged periods of time can
		be an indication that your disk is a bottleneck</strong>.</p>
		<h4>[Physical Disk] "Avg. Disk sec/Read" &amp; "Avg. Disk sec/Write"</h4>
		<p>These both measure the latency of your disks, that is, the average time it takes
		for a disk transfer to complete.&nbsp; Although this value is displayed in seconds
		it is actually accurate down to milliseconds. Good and bad values for these counters
		are really dependent on your hardware.&nbsp; For example, you would expect lower
		values for an SSD as compared to any spinning disk.&nbsp; For counters like this
		I find it best to get a baseline after the hardware is installed and use this value
		going forward to determine if you are experiencing any latency issues related to
		the hardware.</p>
		<h4>[Memory] "Available MBs"</h4>
		<p>The total amount of available memory on the system.&nbsp; <strong>Usually you
		would like to keep about 10% free</strong> but on systems with a really large amounts
		of memory (&gt; 50GB) there can be less available especially if it is a server that
		is dedicated to just a single SQL Server instance.&nbsp; If this value is lower
		than this then it's not necessarily an issue provided the system is not doing 
a lot of paging.&nbsp; If you are paging then further troubleshooting can be done 
to see which individual processes are using most of the memory.</p>
<h4>[Memory] "Pages/sec"&nbsp;</h4>
<p>This is actually the sum of "Pages Input/sec" and "Pages Output/sec" 
counters which is the rate at which pages are being read and written as a result 
of pages faults.&nbsp; Small spikes with this value do not mean there is an issue 
but <strong>sustained values of greater than 50 can mean that system memory is a 
bottleneck</strong>. </p>
</body>
</html>
'@
					}
				}
			}
		}
		'Domain.com' {
			
			#Return Button#
			New-UDRow -Endpoint {
				New-UDColumn -Size 3 -Content {
					New-UDButton -IconAlignment left -Text "Back" -Icon Home -OnClick { Invoke-UDRedirect -Url "$Session:ReturnURL" }
				}
				New-UDColumn -Size 3 -Content { }
				New-UDColumn -Size 3 -Content { }
				New-UDColumn -Size 3 -Content { }
			}
			#Collapsible
			New-UDCollapsible -Items {
				New-UDCollapsibleItem -Title "Server Name : $Session:CurrentServerName, Server IPAddress : $Session:CurrentServerIP" -Icon Info_circle -Content {
					New-UDRow -Endpoint {
						#Server Information Collection 
						$HWinfoQ = "select * from Database01.dbo.ServersHWinfo where ComputerIP = '" + $Session:CurrentServerIP + "'"
						$HWinfo = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $HWinfoQ
						$DiskinfoQ = "select * from Database01.dbo.ServersDisks where ComputerIP = '" + $Session:CurrentServerIP + "'"
						$Diskinfo = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $DiskinfoQ
						$SRVInfQ = "select * from Database01.dbo.Servers where IPAddress = '" + $Session:CurrentServerIP + "'"
						$SRVInf = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $SRVInfQ
						#ServerInfo Table
						New-UDColumn -Size 6 -Content {
							New-UDTable -Title "Server Information" -Style bordered -BackgroundColor '#F2F2F2' -Headers @(" ", " ") -Endpoint {
								@{
									'ComputerName' = $HWinfo.ComputerName
									'OSName'	   = $HWinfo.OSName
									'OSInstallDate' = $HWinfo.OSInstallDate
									'OSServicePackMajorVersion' = $HWinfo.OSServicePackMajorVersion
									'OSArchitecture' = $HWinfo.OSArchitecture
									'OSBuildNumber' = $HWinfo.OSBuildNumber
									'Manufacturer' = $HWinfo.Manufacturer
									'Model'	       = $HWinfo.Model
									'SerialNumber' = $HWinfo.SerialNumber
									'BiosName'	   = $HWinfo.BiosName
									'BiosVersion'  = $HWinfo.BiosVersion
									'MemorySize'   = $HWinfo.MemorySize
									'CPUName'	   = $HWinfo.CPUName
									'TotalCPUCores' = $HWinfo.TotalCPUCores
									'PercentFreeMemory' = $HWinfo.PercentFreeMemory
									'PercentCPUAvgLoad' = $HWinfo.PercentCPUAvgLoad
								}.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
							}
							#Disks Table
						}
						
						New-UDColumn -Size 6 -Content {
							New-UDTable -Style bordered -BackgroundColor '#F2F2F2' -Title "" -Headers ("Drive", "Vol.Name", "Size/GB", "Free/GB", "%Free") -Endpoint {
								$Diskinfo | foreach {
									[PSCustomObject]@{
										DeviceID = $_.DeviceID
										VolumeName = $_.VolumeName
										DiskSizeGB = $_.DiskSizeGB
										DiskFreeSpaceGB = $_.DiskFreeSpaceGB
										PercentFreeDiskSpace = $_.PercentFreeDiskSpace
									}
								} | Out-UDTableData -Property ("DeviceID", "VolumeName", "DiskSizeGB", "DiskFreeSpaceGB", "PercentFreeDiskSpace")
							}
							New-UDTable -Title " " -Style bordered -BackgroundColor '#F2F2F2' -Headers @(" ", " ") -Endpoint {
								@{
									'Asset_ID' = $SRVInf.Asset_ID
									'Vlan'	   = $SRVInf.Vlan
									'Owner'    = $SRVInf.Owner
									'Type'	   = $SRVInf.Type
									'HyperVisor' = $SRVInf.HyperVisor
									'Rack'	   = $SRVInf.Rack
									'Location' = $SRVInf.Location
									'Domain'   = $SRVInf.Domain
									'Backup'   = $SRVInf.Backup
									'ProjectManager' = $SRVInf.ProjectManager
									'Projects' = $SRVInf.Projects
									'Service'  = $SRVInf.Service
									'Function' = $SRVInf.Function
								}.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
							}
						}
					}
				}
				New-UDCollapsibleItem -Title "Server Status" -Active -Icon arrow_circle_right -Endpoint {
					New-UdRow {
						#Automatic Services
						New-UdColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Automatic Services" -TextSize Medium -Endpoint {
								$SVCCT = (Get-Service -ComputerName $Session:CurrentServerName | where { $_.StartType -eq "Automatic" -and $_.Status -eq "Stopped" }).count
								$SVCTXT = "$SVCCT Stopped Services"
								New-UDButton -Text $SVCTXT -Icon stop_circle -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Automatic And Stopped Services" -NoPaging -NoFilter -NoExport -Headers @("Name", "Display Name", "Status") -Properties @("Name", "DisplayName", "Status") -Endpoint {
											Get-Service -ComputerName $Session:CurrentServerName | where { $_.StartType -eq "Automatic" -and $_.Status -eq "Stopped" } | select "Name", "DisplayName", "Status" | Out-UDGridData
										}
									}
								}
							}
						}
						#Antivirus Status
						New-UDColumn -Size 1.5 -Endpoint {
							
							New-UDCard -Title "Antivirus Status" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.AVState where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$AVResult = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$AVTitle = if ($AVResult.IsUpdated -eq "Yes") { "Installed & Updated" }
								else { "Needs Attention" }
								New-UDButton -Text $AVTitle -Icon shield_alt -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Antivirus Details" -NoPaging -NoFilter -NoExport -Headers @("IsInstalled", "SEPVersion", "IsUpdated", "LastUpdated", "State") -Properties @("IsInstalled", "SEPVersion", "IsUpdated", "LastUpdated", "State") -Endpoint {
											$AVResult | select IsInstalled, SEPVersion, IsUpdated, LastUpdated, State | Out-UDGridData
										}
									}
								}
							}
						}
						#FireWall Status
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "FireWall Status" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.FWState where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$FWResult = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$FWTitle = if ($FWResult.DomainProfile -eq "ON") { "FireWall Is ON" }
								else { "Needs Attention" }
								New-UDButton -Text $FWTitle -Icon cloud_upload_alt -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "FireWall Details" -NoPaging -NoFilter -NoExport -Headers @("DomainProfile", "PrivateProfile", "PublicProfile") -Properties @("DomainProfile", "PrivateProfile", "PublicProfile") -Endpoint {
											$FWResult | select DomainProfile, PrivateProfile, PublicProfile | Out-UDGridData
										}
									}
								}
							}
						}
						#Internet Connection
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Internet Connection" -TextSize Medium -Endpoint {
								$Query = "select IsConnected from Database01.dbo.IsInternetConnected where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$IsConnected = (Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query).IsConnected
								$INTTitle = if ($IsConnected -eq "True") { "Connected" }
								else { "Disconnected" }
								New-UDButton -Text $INTTitle -Icon wifi -IconAlignment left
							}
						}
						#Windows Roles
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Windows Roles" -TextSize Medium -Endpoint {
								$Query = "select RoleName from Database01.dbo.WindowsRoles where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$RoleNames = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$RTitle = if ($RoleNames.count -gt 0) { "$($RoleNames.count) Installed" }
								else { "NO Roles Detected" }
								New-UDButton -Text $RTitle -Icon r_project -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Installed Windows Roles" -NoPaging -NoFilter -NoExport -Headers @("RoleName") -Properties @("RoleName") -Endpoint {
											$RoleNames | select RoleName | Out-UDGridData
										}
									}
								}
							}
						}
						#File Shares
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "File Shares" -TextSize Medium -Endpoint {
								$Query = "select ShareName,SharePath,ShareDesc from Database01.dbo.FileShares where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Shares = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$STitle = if (($Shares.ShareName).count -gt 0) { "$(($Shares.ShareName).count) Shares" }
								else { "NO Shared Folders" }
								New-UDButton -Text $STitle -Icon folder -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Shared Folders Information" -NoPaging -NoFilter -NoExport -Headers @("ShareName", "SharePath", "ShareDesc") -Properties @("ShareName", "SharePath", "ShareDesc") -Endpoint {
											$Shares | select ShareName, SharePath, ShareDesc | Out-UDGridData
										}
									}
								}
							}
						}
					}
					New-UDRow {
						#Windows UPTime
						New-UdColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Windows UPTime" -TextSize Medium -Endpoint {
								$Lastreboottime = Get-WmiObject -ComputerName $Session:CurrentServerName Win32_OperatingSystem | select @{ LABEL = 'LastBootUpTime'; EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) } }
								$Uptime = (get-date) - ($Lastreboottime).LastBootUpTime
								$UptimeTitle = "$([math]::Round($($Uptime.TotalHours), 2)) Hours"
								New-UDButton -Text $UptimeTitle -Icon clock -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "UpTime History" -NoPaging -NoFilter -NoExport -Headers @("Startup", "Shutdown", "Uptime /Days", "Uptime /HRs") -Properties @("UStartup", "UShutdown", "UptimeDays", "UptimeHRs") -Endpoint {
											$Uptimes = @()
											$filterHt = @{
												'LogName' = 'System'
												'ID'	  = 6005
											}
											$StartEvents = Get-WinEvent -ComputerName $Session:CurrentServerName -FilterHashtable $filterHt
											$StartTimes = $StartEvents.TimeCreated
											
											## Find all stop events
											$filterHt.ID = 6006
											$StopEvents = Get-WinEvent -ComputerName $Session:CurrentServerName -FilterHashtable $filterHt -Oldest
											$StopTimes = $StopEvents.TimeCreated
											
											foreach ($startTime in $StartTimes)
											{
												$StopTime = $StopTimes | ? { $_ -gt $StartTime } | select -First 1
												if (-not $StopTime)
												{
													$StopTime = Get-Date
												}
												$output = [ordered]@{
													'UStartup'   = $StartTime
													'UShutdown'  = $StopTime
													'UptimeDays' = [math]::Round((New-TimeSpan -Start $StartTime -End $StopTime).TotalDays, 2)
													'UptimeHRs'  = [math]::Round((New-TimeSpan -Start $StartTime -End $StopTime).TotalHours, 2)
												}
												
												$Uptimes += [pscustomobject]$output
												
											}
											$UpTimes | Out-UDGridData
										}
									}
								}
							}
						}
						#.Net FrameWork
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title ".Net FrameWork" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.DotNetVersions where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$DotNetVersions = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$MajorNetVersion = $DotNetVersions | Where { $_.NETFramework -eq "Full" }
								$NTitle = if ($($MajorNetVersion.Version).count -gt 0) { ".Net $($MajorNetVersion.Version)" }
								else { ".Net Not Detected" }
								New-UDButton -Text $NTitle -Icon project_diagram -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Installed .Net FrameWork" -NoPaging -NoFilter -NoExport -Headers @("NETFramework", "Product", "Version", "Release") -Properties @("NETFramework", "Product", "Version", "Release") -Endpoint {
											$DotNetVersions | select NETFramework, Product, Version, Release | Out-UDGridData
										}
									}
								}
							}
						}
						#Pending Reboot
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Pending Reboot" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.PendingReboot where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$PendingReboot = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$IsPendingReboot = $PendingReboot.IsRebootPending
								$RTitle = if ($($PendingReboot.IsRebootPending) -eq "True") { "Reboot is Required" }
								else { "No Reboot Required" }
								New-UDButton -Text $RTitle -Icon power_off -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Pending Reboot Details" -NoPaging -NoFilter -NoExport -Headers @("ComponentBasedServicing", "PendingComputerRenameDomainJoin", "WindowsUpdateAutoUpdate", "IsRebootPending") -Properties @("ComponentBasedServicing", "PendingComputerRenameDomainJoin", "WindowsUpdateAutoUpdate", "IsRebootPending") -Endpoint {
											$PendingReboot | select ComponentBasedServicing, PendingComputerRenameDomainJoin, WindowsUpdateAutoUpdate, IsRebootPending | Out-UDGridData
										}
									}
								}
							}
						}
						#PSversion
						New-UdColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Powershell Version" -TextSize Medium -Endpoint {
								$PSversionMajor = Invoke-Command -ComputerName $Session:CurrentServerName -ErrorAction SilentlyContinue -ScriptBlock { return $PSVersionTable.PSVersion.Major }
								$PSTitle = "Powershell V.$PSversionMajor"
								
								New-UDButton -Text $PSTitle -Icon clock -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UDGrid -Title "Powershell Version Table" -NoPaging -NoFilter -NoExport -Headers @("Major", "Minor", "Build", "Revision") -Properties @("Major", "Minor", "Build", "Revision") -Endpoint {
											$PSversionT = Invoke-Command -ComputerName $Session:CurrentServerName -ErrorAction SilentlyContinue -ScriptBlock { return $PSVersionTable.PSVersion }
											$PSversionT | Out-UDGridData
										}
									}
								}
							}
						}
						#Errors-Warning
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "EventLog Errors" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.ServerLogs where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Logs = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$SystemLogs = $Logs | where { $_.logname -eq "system" }
								$APPLogs = $Logs | where { $_.logname -eq "Application" }
								$NTitle = if ($($Logs.count) -gt 0) { "$($Logs.count) Errors" }
								else { "No Errors Found" }
								New-UDButton -Text $NTitle -Icon exclamation_triangle -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Systems Event Log Errors and Warnings" -NoPaging -NoFilter -NoExport -Headers @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Properties @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Endpoint {
											$SystemLogs | select LogCount, LogID, LogType, LogFirstLogged, LogLastLogged, LogMSG | Out-UDGridData
										}
										New-UdGrid -Title "Applications Event Log Errors and Warnings" -NoPaging -NoFilter -NoExport -Headers @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Properties @("LogCount", "LogID", "LogMSG", "LogType", "LogFirstLogged", "LogLastLogged", "LogName") -Endpoint {
											$APPLogs | select LogCount, LogID, LogType, LogFirstLogged, LogLastLogged, LogMSG | Out-UDGridData
										}
									}
								}
							}
						}
						#Latest Updates
						New-UDColumn -Size 1.5 -Endpoint {
							New-UDCard -Title "Installed Updates" -TextSize Medium -Endpoint {
								$Query = "select * from Database01.dbo.InstalledUpdates where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Updates = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query
								$NTitle = if ($($Updates.count) -gt 0) { "$($Updates.count)Installed" }
								else { "0 Installed" }
								New-UDButton -Text "Installed" -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Latest Installed Updates" -NoPaging -NoFilter -NoExport -Headers @("Description", "HotFixID", "InstalledBy", "InstalledOn", "KBArticle") -Properties @("Description", "HotFixID", "InstalledBy", "InstalledOn", "KBArticle") -Endpoint {
											$Updates | select Description, HotFixID, InstalledBy, InstalledOn, KBArticle | Out-UDGridData
										}
									}
								}
								$Query1 = "select * from Database01.dbo.requiredUpdates where ComputerIP = '" + $Session:CurrentServerIP + "'"
								$Updates1 = Invoke-Sqlcmd -ServerInstance "systemsmgmt" -Query $Query1
								$NTitle1 = if ($($Updates1.count) -gt 0) { "$($Updates1.count)Required" }
								else { "0 Required" }
								New-UDButton -Text "Required" -IconAlignment left -OnClick {
									Show-UDModal -Content {
										New-UdGrid -Title "Required Updates" -NoPaging -NoFilter -NoExport -Headers @("Title", "KBID", "IsBeta", "IsDownloaded", "RebootRequired", "KBarticle") -Properties @("Title", "KBID", "IsBeta", "IsDownloaded", "RebootRequired", "KBarticle") -Endpoint {
											$Updates1 | select Title, KBID, IsBeta, IsDownloaded, RebootRequired, KBarticle | Out-UDGridData
										}
									}
								}
							}
						}
						
						
					}
				}
				New-UDCollapsibleItem -Title "Live Performance Counters:" -Icon chart_line -Content {
					#Charts
					New-UDCard -RevealTitle "Performance Counters" -Endpoint {
						New-UDRow -Endpoint {
							New-UDColumn -Size 4 -Content {
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (% disk time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											#Invoke-Command -Session $Session:CRTPSsession -ScriptBlock {}
											Get-Counter -ComputerName $Session:CurrentServerName '\physicaldisk(_total)\% disk time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (Current disk queue length)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\physicaldisk(_total)\current disk queue length' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "CPU (% processor time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
							}
							New-UDColumn -Size 4 -Content {
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (Avg. Disk sec/Read)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\physicaldisk(_total)\avg. disk sec/read' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "Memory (Available Mbytes)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#8028E842' -ChartBorderColor '#FF28E842' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName 'Memory\Available Mbytes' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "CPU (% Privileged time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\Processor(_Total)\% Privileged time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								
							}
							New-UDColumn -Size 4 -Content {
								New-UDRow -Endpoint {
									New-UdMonitor -BorderWidth 1 -Title "Disk (Avg. Disk sec/Write)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80E8611D' -ChartBorderColor '#FFE8611D' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\physicaldisk(_total)\avg. disk sec/write' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "Memory (Pages/sec)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#8028E842' -ChartBorderColor '#FF28E842' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\Memory\Pages/sec' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
								New-UDRow -Endpoint {
									New-UdMonitor -Title "CPU (% User time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63' -Endpoint {
										try
										{
											Get-Counter -ComputerName $Session:CurrentServerName '\Processor(_Total)\% User time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-UDMonitorData
										}
										catch
										{
											0 | Out-UDMonitorData
										}
									}
								}
							}
						}
					}
					
				}
				New-UDCollapsibleItem -Title "Guide Lines For using Performance Counters:" -Icon arrow_circle_right -Content {
					New-UDCard -Content {
						New-UDHtml -Markup @'
<!DOCTYPE html>
<html>
<head>
<style>
div, dl, dt, dd, ul, ol, li, h1, h2, h3, h4, h5, h6, pre, form, p, blockquote, th, td {
    margin: 0;
    padding: 0;
}

body {
    background: #fff;
    color: #222;
    cursor: auto;
    font-family: "Helvetica Neue", Helvetica, Roboto, Arial, sans-serif;
    font-style: normal;
    font-weight: normal;
    line-height: 1.5;
    margin: 0;
    padding: 0;
    position: relative;
}
p {
    font-family: inherit;
    font-size: 1rem;
    font-weight: normal;
    line-height: 1.6;
    margin-bottom: 1.25rem;
    text-rendering: optimizeLegibility;
}
h4 {
    font-size: 1.15rem;
    color: rgb(0, 77, 113);;
}
h1, h2, h3, h4, h5, h6 {
    color: rgb(0, 77, 113);;
    font-family: "Helvetica Neue", Helvetica, Roboto, Arial, sans-serif;
    font-style: normal;
    font-weight: bold;
    line-height: 1.4;
    margin-bottom: 0.5rem;
    margin-top: 0.2rem;
    text-rendering: optimizeLegibility;
}
</style>
</head>
<body>


<h4>Overview</h4>
<p>When it comes to deciding what to monitor in regards to general server health 
I like to break it down into the following areas: Processor Utilization, Disk Activity, 
Memory Usage . The following set of counters will give you 
a good indication of any issues that could be affecting any of these areas.</p>
<h4>[Processor] "% Processor time"</h4>
<p>This is the percentage of total elapsed time that the processor was busy executing.&nbsp; 
This counter provides a very general measure of how busy the processor is and
<strong>if this counter is constantly high, say above 90%, then you'll need
			to use other counters </strong>(described below) in order to further determine the
			root cause of the CPU pressure.</p>
			<h4>[Processor] "% Privileged time"</h4>
			<p>This measures the percentage of elapsed time the processor spent executing in
			kernel mode.&nbsp; Since this counter takes into account only kernel operations
			(eg. memory management) a high percentage of privileged time, anything consistently
			<strong>above 25%, can usually point to a driver or hardware issue and should be
			investigated.&nbsp; </strong></p>
			<h4>[Processor] "% User time"</h4>
			<p>The percentage of elapsed time the processor spent executing in user mode.&nbsp;
			To describe this simply, it's really the amount of time the processor spent 
executing any user application code.; Generally, even on a dedicated SQL Server, 
I like this number to be consistently <strong>below 65%</strong> as you want to 
have some buffer for both the kernel operations mentioned above as well as any other 
bursts of CPU required by other applications. Anything consistently over 65% 
should be investigated and this might mean digging deeper into exactly what process 
is using the CPU (if it's not SQL Server) by using the "[Process] % User
									time" counter for the individual processes.</p>
		<h4>[Physical Disk] "Current Disk Queue Length" &amp; "Avg. Disk
									Queue Length"</h4>
		<p>The "Current Disk Queue Length" a direct measurement of the disk queue
		length at the time it is sampled so in most cases it is better to monitor "Avg.
									Disk Queue Length" as this value is derived using the (Disk Transfers/sec)*(Disk
			sec/Transfer) counters.&nbsp; Using this calculation gives a much better measure
		of the disk queue over time, smoothing out any quick spikes.&nbsp; Having any physical
		disk with an average <strong>queue length over 2 for prolonged periods of time can
		be an indication that your disk is a bottleneck</strong>.</p>
		<h4>[Physical Disk] "Avg. Disk sec/Read" &amp; "Avg. Disk sec/Write"</h4>
		<p>These both measure the latency of your disks, that is, the average time it takes
		for a disk transfer to complete.&nbsp; Although this value is displayed in seconds
		it is actually accurate down to milliseconds. Good and bad values for these counters
		are really dependent on your hardware.&nbsp; For example, you would expect lower
		values for an SSD as compared to any spinning disk.&nbsp; For counters like this
		I find it best to get a baseline after the hardware is installed and use this value
		going forward to determine if you are experiencing any latency issues related to
		the hardware.</p>
		<h4>[Memory] "Available MBs"</h4>
		<p>The total amount of available memory on the system.&nbsp; <strong>Usually you
		would like to keep about 10% free</strong> but on systems with a really large amounts
		of memory (&gt; 50GB) there can be less available especially if it is a server that
		is dedicated to just a single SQL Server instance.&nbsp; If this value is lower
		than this then it's not necessarily an issue provided the system is not doing 
a lot of paging.&nbsp; If you are paging then further troubleshooting can be done 
to see which individual processes are using most of the memory.</p>
<h4>[Memory] "Pages/sec"&nbsp;</h4>
<p>This is actually the sum of "Pages Input/sec" and "Pages Output/sec" 
counters which is the rate at which pages are being read and written as a result 
of pages faults.&nbsp; Small spikes with this value do not mean there is an issue 
but <strong>sustained values of greater than 50 can mean that system memory is a 
bottleneck</strong>. </p>
</body>
</html>
'@
					}
				}
			}
		}
	}
	
	
}

#endregion Content-Variables

#region DynamicPages

$pages += New-UDPage -Name 'home' -Content {
	New-UDRow {
		New-UDColumn -Size 4 -Content { }
		New-UdColumn -Size 4 -Content {
			New-UDInput -Title "Please Write Your UserName" -Endpoint {
				param ($Name)
				$Session:Privilege = Check-Privilege -User $Name
				$session:IsSysAdmin = Check-IsSysAdmin -User $Name
				if ($Session:Privilege -ne "None")
				{
					Check-RegKey $Name
					Set-RegKey $Name '0'
					New-UDInputAction -RedirectUrl "/dynamic/$Name"
					$OTP = Get-Otp $('"EncString"+2019') 4 60
					#Enable SMS in Production.
					#$SMS = Send-SMS  "$((Get-aduser -identity $Name -Properties extensionAttribute5).extensionAttribute5)" $('Your OTP is ' + $OTP)
					$Session:a = $OTP
				}
				else
				{
					$ErrMSG = "Wrong user Name or you don't have Permission Contact System Administrator"
					Show-UDToast -Message $ErrMSG -Duration 5000 -Position bottomRight -Icon "bug" -IconColor "black" -Balloon -Broadcast -CloseOnClick
				}
				
			}
			
		}
		New-UDColumn -Size 4 -Content { }
	}
	
}
$pages += New-UDPage -Url "/dynamic/:Name" -Endpoint {
	param ($Name)
	#If You Are Testing Enable This#
	New-UDCard -Title "Welcome to The Portal ,$((Get-aduser -identity $Name -Properties displayName).displayName) , OTP is $Session:a !" -Text "Please write the OTP you recieved on your Mobile to continue"
	#ForProduction Enable This#
	#New-UDCard -Title "Welcome to The Portal ,$((Get-aduser -identity $Name -Properties displayName).displayName) ." -Text "Please write the OTP you recieved on your Mobile to continue"
	New-UDRow {
		New-UDColumn -Size 4 -Content { }
		New-UdColumn -Size 4 -Content {
			
			New-UDInput -Title "" -Id "OTPForm" -Content {
				New-UDInputField -Type "textbox" -Name "UserOTP" -Placeholder "OTP"
			} -Endpoint {
				param ($UserOTP)
				if ($UserOTP -eq $Session:a)
				{
					$key = Get-RegKey $Name
					if ($key -eq '0')
					{
						New-UDInputAction -RedirectUrl "/Servers-Information"
						$Session:LoggedInUser = $Name
						Set-RegKey $Name '1'
					}
				}
				else
				{
					New-UDInputAction -Toast "OTP is wrong please Enter it again"
				}
				
			}
			
		}
		New-UDColumn -Size 4 -Content { }
	}
	
}

#endregion DynamicPages

#region Static Pages & Navigation
$Page1 = New-UDPage -Name "Servers Information" -Content { $GridData }
$Page2 = New-UDPage -Name "ServerRequestForm" -Content { $ServerRequestForm }
$Page3 = New-UDPage -Name "Backup State" -Content { $BKBStatusGrid }
$Page4 = New-UDPage -Name "Tower1 Datacenter" -Content { $Tower1 }
$Page5 = New-UDPage -Name "Tower2 Datacenter" -Content { $Tower2Grid }
$Page6 = New-UDPage -Name "Tower3 Datacenter" -Content { $Tower3Grid }
$Page7 = New-UDPage -Name "Virtual Servers" -Content { $VMSGrid }
$Page8 = New-UDPage -Name "Physical Servers" -Content { $PServersGrid }
$Page9 = New-UDPage -Name "VLan_All" -Content { $VLan_All }
$Page10 = New-UDPage -Name "VLan_Tower2" -Content { $VLan_Tower2 }
$Page11 = New-UDPage -Name "VLan_Tower1" -Content { $VLan_Tower1 }
$Page12 = New-UDPage -Name "VLan_Tower3" -Content { $VLan_Tower3 }
$Page13 = New-UDPage -Name "VLans Table" -Content { $VLans_Table }
$Page14 = New-UDPage -Name "Tower1_DC_RackView" -Content { $Tower1_DC_RackView }
$Page15 = New-UDPage -Name "ALL_Published_Servers" -Content { $ALL_Published_Servers }
$Page16 = New-UDPage -Name "F5_DMZ_VIPS" -Content { $F5_DMZ_VIPS }
$Page17 = New-UDPage -Name "F5_Internal_VIPS" -Content { $F5_Internal_VIPS }
$Page18 = New-UDPage -Name "LB_Internal_URLs" -Content { $LB_Internal_URLs }
$Page19 = New-UDPage -Name "All_Public_URLs" -Content { $All_Public_URLs }
$Page20 = New-UDPage -Name "Public_IPs" -Content { $Public_IPs }
$Page21 = New-UDPage -Name "HA_Public_URLs" -Content { $HA_Public_URLs }
$Page22 = New-UDPage -Name "Single_Public_URLs" -Content { $Single_Public_URLs }
$Page23 = New-UDPage -Name "Published_Servers" -Content { $Published_Servers }
$Page24 = New-UDPage -Name "Tower2_DC_RackView" -Content { $Tower2_DC_RackView }
$Page25 = New-UDPage -Name "HypervGrid" -Content { $HypervGrid }
$Page26 = New-UDPage -Name "VmwareGrid" -Content { $VmwareGrid }
$Page27 = New-UDPage -Name "OVMGrid" -Content { $OVMGrid }
$Page28 = New-UDPage -Name "ServerInfo" -Content { $ServerInfo }
$pages += ($Page1, $Page2, $Page3, $Page4, $Page5, $Page6, $Page7, $Page8, $Page9,
	$Page10, $Page11, $Page12, $Page13, $Page14, $Page15, $Page16, $Page17, $Page18,
	$Page19, $Page20, $Page21, $Page22, $Page23, $Page24, $Page25, $Page26, $Page27,
	$Page28)

$NavBarLinks = @((New-UDLink -Text "Relogin" -Url "/home" -Icon home))

$Navigation = New-UDSideNav -Content {
	New-UDSideNavItem -Text "Servers Inventory" -PageName "Servers Information" -Icon Home
	New-UDSideNavItem -Text "Detailed Server Infos" -Icon info_circle -Children {
		New-UDSideNavItem -Text "Backup State" -PageName "Backup State" -Icon info
		New-UDSideNavItem -Text "Data Centers" -Icon building -Children {
			New-UDSideNavItem -Text "Tower1 Datacenter" -PageName "Tower1 Datacenter" -Icon building
			New-UDSideNavItem -Text "Tower1 DC RackView" -PageName "Tower1_DC_RackView" -Icon building
			New-UDSideNavItem -Text "Tower2 Datacenter" -PageName "Tower2 Datacenter" -Icon building
			New-UDSideNavItem -Text "Tower2 DC RackView" -PageName "Tower2_DC_RackView" -Icon building
			New-UDSideNavItem -Text "Tower3 Datacenter" -PageName "Tower3 Datacenter" -Icon building
		}
		New-UDSideNavItem -Text "Server Type" -Icon server -Children {
			New-UDSideNavItem -Text "Virtual Servers" -Icon server -Children {
				New-UDSideNavItem -Text "All Virtual Servers" -PageName "Virtual Servers" -Icon Server
				New-UDSideNavItem -Text "Hyperv VMs" -PageName "HypervGrid" -Icon Server
				New-UDSideNavItem -Text "VMWare VMs" -PageName "VmwareGrid" -Icon Server
				New-UDSideNavItem -Text "OVM VMs" -PageName "OvmGrid" -Icon Server
			}
			New-UDSideNavItem -Text "Physical Servers" -PageName "Physical Servers" -Icon Server
		}
		New-UDSideNavItem -Text "Network Information" -Icon network_wired -Children {
			New-UDSideNavItem -Text "VLANs" -Icon network_wired -Children {
				New-UDSideNavItem -Text "ALL" -PageName "VLan_All" -Icon network_wired
				New-UDSideNavItem -Text "Tower2 Vlans" -PageName "VLan_Tower2" -Icon network_wired
				New-UDSideNavItem -Text "Tower1 Vlan" -PageName "VLan_Tower1" -Icon network_wired
				New-UDSideNavItem -Text "Tower3 Vlan" -PageName "VLan_Tower3" -Icon network_wired
				New-UDSideNavItem -Text "VLans Table" -PageName "VLans Table" -Icon network_wired
			}
			New-UDSideNavItem -Text "Published Servers" -Icon network_wired -Children {
				New-UDSideNavItem -Text "ALL Published Servers" -PageName "ALL_Published_Servers" -Icon network_wired
				New-UDSideNavItem -Text "F5 DMZ VIPS" -PageName "F5_DMZ_VIPS" -Icon network_wired
				New-UDSideNavItem -Text "F5 Internal VIPS" -PageName "F5_Internal_VIPS" -Icon network_wired
				New-UDSideNavItem -Text "LB Internal URLs" -PageName "LB_Internal_URLs" -Icon network_wired
				New-UDSideNavItem -Text "Public Urls" -Icon network_wired -Children {
					New-UDSideNavItem -Text "All Public URLs" -PageName "All_Public_URLs" -Icon network_wired
					New-UDSideNavItem -Text "Public IPs" -PageName "Public_IPs" -Icon network_wired
					New-UDSideNavItem -Text "HA Public URLs" -PageName "HA_Public_URLs" -Icon network_wired
					New-UDSideNavItem -Text "Single Public URLs" -PageName "Single_Public_URLs" -Icon network_wired
					New-UDSideNavItem -Text "Published Servers" -PageName "Published_Servers" -Icon network_wired
				}
			}
			
		}
	}
}
#-Fixed

#endregion Static Pages & Navigation

#region DashBoard Variable
$theme = Get-UDTheme DarkDefault
$MyDashboard = New-UDDashboard -Title "IT Portal" -NavbarLinks $NavBarLinks -Pages $pages -Navigation $Navigation -EndpointInitialization $EndpointInit -Theme $theme

#endregion DashBoard Variable

#region Start-Stop-DashBoard
Get-UDDashboard | Stop-UDDashboard

Start-UDDashboard -Port 85 -Dashboard $MyDashboard

Start-Process http://localhost:85

#endregion Start-Stop-DashBoard
