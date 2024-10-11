param virtualNetworkId string
param virtualNetworkName string
param privateDnsZoneNames array

// Create a private DNS zone link for each privatelink DNS zone
resource virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: '${privateDnsZoneName}/${virtualNetworkName}-link'
  location: 'Global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: []
}]
