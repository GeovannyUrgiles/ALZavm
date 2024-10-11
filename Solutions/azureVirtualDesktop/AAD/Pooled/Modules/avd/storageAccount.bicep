param location string
param CAFPrefix string
param pepSubnetId string
param privateDNSZoneIdStorageFile string
param tags object

resource storageaccounts 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  scope: resourceGroup('nbbprdwusavdrg01')
  name: '${CAFPrefix}poolsa1'
  // location: location
  // tags: tags
  // sku: {
  //   name: 'Premium_LRS'
  // }
  // kind: 'FileStorage'
}

// Create Private Endpoints for Storage Sub Resources in Core

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2021-08-01'  = {
  name: '${CAFPrefix}poolsa1filepe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${CAFPrefix}poolsa1pe'
        properties: {
          privateLinkServiceId: storageaccounts.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${CAFPrefix}poolsa1filenic'
    ipConfigurations: []
    customDnsConfigs: []
  }
  dependsOn: [

  ]
}

// Private DNS Zone Groups / Storage Blob

resource privateDnsZoneGroupsBlob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'storageAccountDiagnostics.bicep.privateDNSZoneGroupsVaultFile'
  parent: privateEndpoints
    properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDNSZoneIdStorageFile
                }
      }
    ]
  }    
}
