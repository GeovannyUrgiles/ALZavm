param vwanResourceGroupName string
param vwanHubName string
param virtualNetwork string
param virtualNetworkResourceId string
param conSubscriptionId string
param defaultRouteTableName string

// Connect vNets to vWan Hub

resource hubVirtualNetworkConnections 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: '${virtualNetwork}-to-${vwanHubName}'
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: resourceId('/subscriptions/${conSubscriptionId}/resourceGroups/${vwanResourceGroupName}/providers/Microsoft.Network/virtualHubs/${vwanHubName}/hubRouteTables', defaultRouteTableName)
      }
      propagatedRouteTables: {
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', vwanHubName, 'defaultRouteTable')
          }
        ]
        labels: []
      }
    }
    remoteVirtualNetwork: {
      id: virtualNetworkResourceId
    }
    enableInternetSecurity: true
  }
  dependsOn: [
    
  ]
}

