param dataLakeStorageDefaultContainerName string
param dataLakeStorageFlatfileContainerName string
param dataLakeStorageFrameworkContainerName string

param pepSubnetId string
param logAnalyticsWorkspaceId string
param location string
param adlsName string
param tags object
param privateDnsZoneNameDfs string
param privateDnsZoneNameFile string
param privateDnsZoneNameBlob string
param privateDnsZoneNameTable string
param privateDnsZoneNameQueue string
param privateDnsZoneIdDfs string
param privateDnsZoneIdFile string
param privateDnsZoneIdBlob string
param privateDnsZoneIdTable string
param privateDnsZoneIdQueue string
param managedIdentityName string
param dataResourceGroupName string
param keyVaultName string
param keyName string
param dataLakeSubResourceNames array

// Reference existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Reference existing User Assigned Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(dataResourceGroupName)
  name: managedIdentityName
}

// Create Azure Data Lake Storage
resource dataLake 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: adlsName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    accessTier: 'Hot'
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      identity: {
        userAssignedIdentity: userAssignedIdentity.id
      }
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: keyName
        keyvaulturi: keyVault.properties.vaultUri
      }
    }
  }
  dependsOn: []
}

// Create Default Containers
resource DataLakeStorageFlatfileContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${adlsName}/default/${dataLakeStorageFlatfileContainerName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    dataLake
  ]
}

resource dataLakeStorageFrameworkContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${adlsName}/default/${dataLakeStorageFrameworkContainerName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    dataLake
  ]
}

resource DataLakeStorageDefaultContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: '${adlsName}/default/${dataLakeStorageDefaultContainerName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    dataLake
  ]
}

// Send Transaction Logs to Log Analytics Workspace
resource transLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: dataLake
  name: 'diag-${adlsName}-transactionlogs'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: []
    metrics: [
      {
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
        category: 'Transaction'
      }
    ]
  }
}

// Create Private Endpoints for Storage Sub Resources in Core
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2024-01-01' = [
  for (dataLakeSubResourceName, i) in dataLakeSubResourceNames: {
    name: toLower('${dataLake.name}-${dataLakeSubResourceName}-pe01')
    location: location
    tags: tags
    properties: {
      privateLinkServiceConnections: [
        {
          name: toLower('${dataLake.name}-${dataLakeSubResourceName}-pe01')
          properties: {
            privateLinkServiceId: dataLake.id
            groupIds: [
              dataLakeSubResourceName
            ]
          }
        }
      ]
      subnet: {
        id: pepSubnetId
      }
      customNetworkInterfaceName: toLower('${dataLake.name}-${dataLakeSubResourceName}-pe-nic01')
      ipConfigurations: []
      customDnsConfigs: []
    }
    dependsOn: []
  }
]

// Private DNS Zone Groups / File Core
resource privatednszonegroupsfile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'privateDNSZoneGroupsFile'
  parent: privateEndpoints[0]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameFile
        properties: {
          privateDnsZoneId: privateDnsZoneIdFile
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints
  ]
}

// Private DNS Zone Groups / Blob Core
resource privatednszonegroupsblob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'privateDNSZoneGroupsBlob'
  parent: privateEndpoints[1]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameBlob
        properties: {
          privateDnsZoneId: privateDnsZoneIdBlob
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoints
  ]
}

// Private DNS Zone Groups / Table Core
resource privatednszonegroupstable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'privateDNSZoneGroupsTable'
  parent: privateEndpoints[2]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameTable
        properties: {
          privateDnsZoneId: privateDnsZoneIdTable
        }
      }
    ]
  }
}

// Private DNS Zone Groups / Queue Core
resource privatednszonegroupsqueue 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'privateDNSZoneGroupsQueue'
  parent: privateEndpoints[3]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameQueue
        properties: {
          privateDnsZoneId: privateDnsZoneIdQueue
        }
      }
    ]
  }
}

// Private DNS Zone Groups / Queue Core
resource privatednszonegroupsdfs 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'privateDNSZoneGroupsDfs'
  parent: privateEndpoints[4]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameDfs
        properties: {
          privateDnsZoneId: privateDnsZoneIdDfs
        }
      }
    ]
  }
}

output privateEndpoints_fileId string = privateEndpoints[0].id
output privateEndpoints_blobId string = privateEndpoints[1].id
output privateEndpoints_tableId string = privateEndpoints[2].id
output privateEndpoints_queueId string = privateEndpoints[3].id
output privateEndpoints_dfsId string = privateEndpoints[4].id
output storageAccountId string = dataLake.id
output dataLakeId string = dataLake.id
output dataLakeName string = dataLake.name

output dataLakeRootStorageUrl string = 'https://${adlsName}.dfs.${environment().suffixes.storage}'
