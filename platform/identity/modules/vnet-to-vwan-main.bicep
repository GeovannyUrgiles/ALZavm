targetScope = 'managementGroup'

param vwanResourceGroupName string = 'concusnetworkrg'
param vwanHubName string = 'concusvwanhub'
param conSubscriptionId string = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43'

param virtualNetworks array = [
  {
    name: 'idneus2vnet'
    resourceId: '/subscriptions/5a718e73-cce6-49e2-af77-023ea133c332/resourceGroups/idneus2networkrg/providers/Microsoft.Network/virtualNetworks/idneus2vnet'
  }
]

// Reference Existing Virtual WAN Hub

resource virtualHubs 'Microsoft.Network/virtualHubs@2024-01-01' existing = {
  scope: resourceGroup(conSubscriptionId, vwanResourceGroupName)
  name: vwanHubName
}

// Connect vNets to vWan Hub

module virtualNetworkConnections 'vnet-to-vhub.bicep' = [
  for i in range(0, length(virtualNetworks)): {
    name: '${virtualNetworks[i].name}-to-${vwanHubName}'
    scope: resourceGroup(conSubscriptionId, vwanResourceGroupName)
    params: {
      vwanResourceGroupName: vwanResourceGroupName
      vwanHubName: vwanHubName
      conSubscriptionId: conSubscriptionId
      virtualNetwork: virtualNetworks[i].name
      virtualNetworkResourceId: virtualNetworks[i].resourceId
      defaultRouteTableName: 'defaultRouteTable'
    }
  }
]
