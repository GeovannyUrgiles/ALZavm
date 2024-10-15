
param spokeCAFPrefixes string
param location string
param tags object

param pepSubnetId string

param storageAccountName string = '${spokeCAFPrefixes}diagst01'
param storageAccountKind string = 'StorageV2'
param storageAccountSku string = 'Standard_LRS'

param privateDNSZoneNameStorageBlob string

// Tag Set for the Default Diagnostics Storage in each Subscription / Do Not Change / Cloud Control
param tagsDiag object = {
  DiagStorage: 'SubDefaultDiag'
}
param tagsDiagStorage object = union(tags, tagsDiag)

var storageSubResourceNames = [
  // 'file'
  'blob'
  // 'table'
  // 'queue'
  // 'dfs'
  // 'web'
]

resource storageaccounts 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags: tagsDiagStorage
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

// Create Private Endpoints for Storage Sub Resources in Core

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2021-08-01'  = [for storageSubResourceName in storageSubResourceNames: {
  name: '${storageAccountName}${storageSubResourceName}pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}pe'
        properties: {
          privateLinkServiceId: storageaccounts.id
          groupIds: [
            storageSubResourceName
          ]
        }
      }
    ]
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${storageAccountName}${storageSubResourceName}nic'
    ipConfigurations: []
    customDnsConfigs: []
  }
  dependsOn: [

  ]
}]

// Private DNS Zone Groups / Storage Blob

resource privateDnsZoneGroupsBlob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'storageAccountDiagnostics.bicep.privateDNSZoneGroupsVaultBlob'
  parent: privateEndpoints[0]
    properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDNSZoneNameStorageBlob
                }
      }
    ]
  }    
}

output storageAccountId string = storageaccounts.id
output storageAccountName string = storageaccounts.name
