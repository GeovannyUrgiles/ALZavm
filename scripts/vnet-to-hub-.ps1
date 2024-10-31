This script creates a connection between the virtual hub and the virtual network. The connection allows traffic to flow between the virtual network and the virtual hub. 

Connect-AzAccount

$resourceGroup = Get-AzResourceGroup -ResourceGroupName "concusnetworkrg" 
$virtualWan = Get-AzVirtualWan -ResourceGroupName "concusnetworkrg" -Name "concusvwan"
$virtualHub = Get-AzVirtualHub -ResourceGroupName "concusnetworkrg" -Name "concusvwanhub"
$remoteVirtualNetwork = Get-AzVirtualNetwork -Name "idncusvnet" -ResourceGroupName "idncusnetworkrg"

New-AzVirtualHubVnetConnection -ResourceGroupName $resourceGroup -VirtualHubName $virtualHub -Name "vnet-connection" -RemoteVirtualNetwork $remoteVirtualNetwork -VirtualWan $virtualWan -AllowBranchToBranchTraffic $true -AllowHubToBranchTraffic $true -AllowVnetToVnetTraffic $true -RoutingConfiguration "Default"
 
 
 
 