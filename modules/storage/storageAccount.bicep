param storageAccountName string
param location string
param tags object
param privateDnsZoneIdBlob string
param privateDnsZoneIdFile string
param privateDnsZoneIdTable string
param privateDnsZoneIdQueue string
param pepSubnetId string
param storageAccountKind string = 'StorageV2'
param storageAccountSku string = 'Standard_LRS'
param storageSubResourceNames array = [
  'file'
  'blob'
  'table'
  'queue'
  // 'dfs'
  // 'web'
]

resource storageaccounts 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags: tags
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

resource privateendpoints 'Microsoft.Network/privateEndpoints@2021-05-01' = [for (storageSubResourceName, i) in storageSubResourceNames: {
  name: '${storageAccountName}${storageSubResourceName}pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}${storageSubResourceName}pe'
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

// Private DNS Zone Groups / File Core

resource privatednszonegroupsfile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'privateDNSZoneGroupsFile'
  parent: privateendpoints[0]
    properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneIdFile
                }
      }
    ]
  }    
}

// Private DNS Zone Groups / Blob Core

resource privatednszonegroupsblob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'privateDNSZoneGroupsBlob'
  parent: privateendpoints[1]
    properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneIdBlob
                }
      }
    ]
  }    
}

// Private DNS Zone Groups / Table Core

resource privatednszonegroupstable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'privateDNSZoneGroupsTable'
  parent: privateendpoints[2]
    properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneIdTable
                }
      }
    ]
  }    
}

// Private DNS Zone Groups / Queue Core

resource privatednszonegroupsqueue 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'privateDNSZoneGroupsQueue'
  parent: privateendpoints[3]
    properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneIdQueue
                }
      }
    ]
  }    
}

output storageAccountId string = storageaccounts.id
output privateEndpoints_fileId string = privateendpoints[0].id
output privateEndpoints_blobId string = privateendpoints[1].id
output privateEndpoints_tableId string = privateendpoints[2].id
output privateEndpoints_queueId string = privateendpoints[3].id
// output privateEndpoints_dfsId string = privateendpoints[4].id
// output privateEndpoints_webId string = privateendpoints[5].id
