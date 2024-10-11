//Used for routing through NVA
param customerNaming string
param location string 
param tags object

resource routeTable 'Microsoft.Network/routeTables@2021-05-01' = {
  name: '${customerNaming}rt'
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'all-to-cp'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.70.4.4'
          hasBgpOverride: false
        }
      }
    ]
  }
}
resource routes 'Microsoft.Network/routeTables/routes@2021-05-01' = {
  parent: routeTable
  name: 'all-to-cp'
  properties: {
    addressPrefix: '0.0.0.0/0'
    nextHopType: 'VirtualAppliance'
    nextHopIpAddress: '10.70.4.4'
    hasBgpOverride: false
  }
}
output routetableId string = routeTable.id
