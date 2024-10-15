param virtualNetworkId string
param virtualNetworkName string
param privatelinkDnsZoneNames array

resource privatednszonelinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for privatelinkDnsZoneName in privatelinkDnsZoneNames: {
  name: '${privatelinkDnsZoneName}/${privatelinkDnsZoneName}-to-${virtualNetworkName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
  dependsOn: [
  ]
}]
