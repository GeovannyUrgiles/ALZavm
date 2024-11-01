param virtualWanHubName string
param virtualNetworkSpokeName string
// param friendlyName string
param location string
param virtualNetworkSpokeId string
param coreSubscriptionIds string

targetScope = 'resourceGroup'

// Resource Group

//resource resourceGroupPeeringCore 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
//  scope: subscription(coreSubscriptionIds)
//  name: resourceGroupNetworkCore
//}

// Declare Virtual Hub Parent

resource virtualHubs 'Microsoft.Network/virtualHubs@2024-01-01' existing = {
  name: virtualWanHubName
}

// Connect Spoke VNets to Vwan Hub

resource hubVirtualNetworkConnections 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: '${virtualWanHubName}-to-${virtualNetworkSpokeName}'
  parent: virtualHubs
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id:  resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualWanHubName, 'defaultRouteTable')
      }
      propagatedRouteTables: {
        ids: [
          {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualWanHubName, 'defaultRouteTable')
          }
        ]
        labels: [
          'default'
        ]
      }
    }
    remoteVirtualNetwork: {
      id: virtualNetworkSpokeId
    }
    enableInternetSecurity: true
  }
  dependsOn: [
    
  ]
}
