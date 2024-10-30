This script creates a connection between the virtual hub and the virtual network. The connection allows traffic to flow between the virtual network and the virtual hub. 

$resourceGroup = Get-AzResourceGroup -ResourceGroupName "TestRG" 
$virtualWan = Get-AzVirtualWan -ResourceGroupName "TestRG" -Name "TestVWAN1"
$virtualHub = Get-AzVirtualHub -ResourceGroupName "TestRG" -Name "Hub1"
$remoteVirtualNetwork = Get-AzVirtualNetwork -Name "VNet1" -ResourceGroupName "TestRG"

New-AzVirtualHubVnetConnection -ResourceGroupName $resourceGroup -VirtualHubName $virtualHub -Name "VNet1-connection" -RemoteVirtualNetwork $remoteVirtualNetwork -VirtualWan $virtualWan -AllowBranchToBranchTraffic $true -AllowHubToBranchTraffic $true -AllowVnetToVnetTraffic $true -RoutingConfiguration "Default"
 
 
 
 