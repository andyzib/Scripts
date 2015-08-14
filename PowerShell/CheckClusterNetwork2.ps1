#-------------------------------------------------
#Finds Why HA network is not reported as HA by VMM
#-------------------------------------------------

function CompareList($list1, $list2)
{
	if( $list1.count -ne $list2.count )
	{
		return $false
	}

	for($ndx = 0; $ndx -lt $list1.count ; $ndx++)
	{
		if( $list1[$ndx].ToString() -ne $list2[$ndx].ToString() )
		{
			return $false
		}
	}

	return $true
}

function ValidateHANetwork($clusterName, $switchName)
{
	$validationResult = $true
	$cluster = get-scvmhostcluster -name $clusterName

	$vNic = Get-SCVirtualNetwork -VMHost $cluster.nodes[0] | where {$_.name -eq $switchName}
	if( $vNic -eq $null )
	{
		Write-Host "Virtual Switch not found in host "  $cluster.nodes[0].Name
		$validationResult = $false
	}
	else
	{
	if( $vNic.VMHostNetworkAdapters.Count -eq 0 )
	{
		Write-Host "Virtual Switch not attached to external network card on host " + $cluster.nodes[0].Name
		$validationResult = $false

	}
	else
	{
		foreach($node in $cluster.nodes)
		{
			Write-Host "==========================================================================="
			Write-Host "Comparing " $node.Name
			Write-Host "==========================================================================="

			$vNicToCompare = Get-SCVirtualNetwork -VMHost $node | where {$_.name -eq $switchName}
			if( $vNicToCompare -eq $null )
			{
				$validationResult = $false
				Write-Host "Virtual Switch not found in host "  $node.Name
			}
		
			if( $vNicToCompare.VMHostNetworkAdapters.Count -eq 0)
			{
				$validationResult = $false
				Write-Host "Virtual Switch not attached to external network card on host "  $node.Name
			}
	
			if( $vNic.VMHostNetworkAdapters[0].LogicalNetworks -eq $null )
			{
				if( $vNicToCompare.VMHostNetworkAdapters[0].LogicalNetworks -ne $null )
				{
					$validationResult = $false
					Write-Host "Net Adapter " $vNic.VMHostNetworkAdapters.Name  " for "  $cluster.nodes[0].name  " is not connected to logical network but Net adapter " $vNicToCompare.VMHostNetworkAdapters.Name " for " $node.Name
				}
			}
			else
			{
				$ln1 = @($vNic.VMHostNetworkAdapters[0].LogicalNetworks | Sort-Object Name)
				$ln2 = @($vNicToCompare.VMHostNetworkAdapters[0].LogicalNetworks | Sort-Object Name)

				$ln1Id = @($vNic.VMHostNetworkAdapters[0].LogicalNetworks | Sort-Object ID | select ID)
				$ln2Id = @($vNicToCompare.VMHostNetworkAdapters[0].LogicalNetworks | Sort-Object ID | select ID)
	
				$result = CompareList $ln1Id $ln2Id
				
				if( $result -eq $false )
				{
					Write-Host "Logical Networks on Adapters don't match"
					Write-Host "------------------------------------------------"
					Write-Host "Host " $cluster.nodes[0].name " Logical networks for adapter "  $vNic.VMHostNetworkAdapters[0].Name 
					@($ln1) | ft *
					Write-Host "------------------------------------------------"
					Write-Host "Host " $node.name " Logical networks for adapter "  $vNicToCompare.VMHostNetworkAdapters[0].Name 
					@($ln2) | ft *
					Write-Host "------------------------------------------------"
		
					$validationResult = $false
				}
				else
				{
					$sub1 = @($vNic.VMHostNetworkAdapters[0].SubnetVLans | Sort-Object Name)
					$sub2 = @($vNicToCompare.VMHostNetworkAdapters[0].SubnetVLans | Sort-Object Name)
		
					$sub1Id = @($vNic.VMHostNetworkAdapters[0].SubnetVLans | Sort-Object ID | select ID)
					$sub2Id = @($vNicToCompare.VMHostNetworkAdapters[0].SubnetVLans | Sort-Object ID | select ID)
		
					$result = CompareList $sub1Id $sub2Id
					
					if( $result -eq $false )
					{
						Write-Host "Subnets on Adapters don't match"
						Write-Host "------------------------------------------------"
						Write-Host "Host " $cluster.nodes[0].name " Subnets"
						@($sub1) | ft *
						Write-Host "------------------------------------------------"
						Write-Host "Host " $node.name " Subnets"
						@($sub2) | ft *
						Write-Host "------------------------------------------------"
			
						$validationResult = $false
					}
                    else
                    {
                        if( $vNic.VMHostNetworkAdapters[0].VLanMode -ne $vNicToCompare.VMHostNetworkAdapters[0].VLanMode )
                        {
                        	Write-Host "VlanModes on Adapters don't match"
						    Write-Host "------------------------------------------------"
						    Write-Host "Host " $cluster.nodes[0].name " Subnets"
						    $vNic.VMHostNetworkAdapters[0].VLanMode
						    Write-Host "------------------------------------------------"
						    Write-Host "Host " $node.name " Subnets"
						    $vNicToCompare.VMHostNetworkAdapters[0].VLanMode
						    Write-Host "------------------------------------------------"
			
						    $validationResult = $false
                        }
                    }
				}
			}
		}
	}
	}	
	return $validationResult
}


if ($args.Length -ne 2 )
{
	Write-Host "Usage: CheckClusterNetwork <clusterName> <switchName>" 
}
else
{
	$result = ValidateHANetwork $args[0] $args[1]

	if( $result -eq $true)
	{
		Write-Host "The cluster virutal network is HA and is configured correctly"
	}
}
