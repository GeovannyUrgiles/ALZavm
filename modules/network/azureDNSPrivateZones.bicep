param privateDnsZoneNames array
param tags object

resource privatednszones 'Microsoft.Network/privateDnsZones@2018-09-01' = [for privateDnsZoneName in privateDnsZoneNames: {
  name: '${privateDnsZoneName}'
  location: 'global'
  tags: tags
  properties: {
  }
  dependsOn: [
  ]
}]
