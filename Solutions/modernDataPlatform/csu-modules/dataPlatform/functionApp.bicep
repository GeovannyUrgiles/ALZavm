param tags object

param functionAppName string
param componentsName string = functionAppName
param location string
param keyVaultName string
param keyName string
param functionAppSubnetId string
param pepSubnetId string
param logAnalyticsWorkspaceId string
param privateDnsZoneIdWebsites string
param privateDnsZoneNameWebsites string
param privateDnsZoneNameBlob string
param privateDnsZoneNameFile string
param privateDnsZoneNameQueue string
param privateDnsZoneNameTable string
param privateDnsZoneIdBlob string
param privateDnsZoneIdFile string
param privateDnsZoneIdQueue string
param privateDnsZoneIdTable string
param dataResourceGroupName string
param userAssignedIdentityId string
param managedIdentityName string
param env string

param productionSkus bool
param sku object

// Reference existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Reference existing user assigned identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(dataResourceGroupName)
  name: managedIdentityName
}

// Create Function App Service Plan
module appServicePlan 'fnAppServicePlan.bicep' = {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-fnAppServicePlan'
  params: {
    serverfarmsName: '${functionAppName}-asp'
    sku: (productionSkus ? sku.prod : sku.nonprod)
    location: location
    tags: tags
  }
  dependsOn: []
}

// Storage Account
resource storageAccounts 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(replace('${functionAppName}', '-', 'sa'))
  location: location
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
}

resource storageAccounts_blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccounts
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

resource storageAccounts_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccounts_blob
  name: 'azure-webjobs-hosts'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: []
}

resource storageAccounts_azure_webjobs_secrets 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccounts_blob
  name: 'azure-webjobs-secrets'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: []
}

resource storageAccounts_fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccounts
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource storageAccounts_fileServices_share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  parent: storageAccounts_fileServices
  name: toLower(functionAppName)
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
  }
  dependsOn: []
}

resource Microsoft_queueServices 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: storageAccounts
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource storageAccounts_tableServices 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: storageAccounts
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// Private Endpoint Blob

resource privateEndpointsBlob 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${storageAccounts.name}-blob-pe01'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccounts.name}-blob-pe01'
        properties: {
          privateLinkServiceId: storageAccounts.id
          groupIds: [
            'blob'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${storageAccounts.name}-blob-pe-nic01'
    subnet: {
      id: pepSubnetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private Endpoint File
resource privateEndpointsFile 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${storageAccounts.name}-file-pe01'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccounts.name}-file-pe01'
        properties: {
          privateLinkServiceId: storageAccounts.id
          groupIds: [
            'file'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${storageAccounts.name}-file-pe-nic01'
    subnet: {
      id: pepSubnetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private Endpoint Queue
resource privateEndpointsQueue 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${storageAccounts.name}-queue-pe01'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccounts.name}-queue-pe01'
        properties: {
          privateLinkServiceId: storageAccounts.id
          groupIds: [
            'queue'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${storageAccounts.name}-queue-pe-nic01'
    subnet: {
      id: pepSubnetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private Endpoint Table
resource privateEndpointsTable 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${storageAccounts.name}-table-pe01'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${storageAccounts.name}-table-pe01'
        properties: {
          privateLinkServiceId: storageAccounts.id
          groupIds: [
            'table'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${storageAccounts.name}-table-pe-nic01'
    subnet: {
      id: pepSubnetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private Endpoint Blob DNS Zone Group
resource privateDnsZoneGroupsBlob 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpointsBlob
  name: 'default'
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
  dependsOn: []
}

// Private Endpoint File DNS Zone Group
resource privateDnsZoneGroupsFile 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpointsFile
  name: 'default'
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
  dependsOn: []
}

// Private Endpoint Queue DNS Zone Group
resource privateDnsZoneGroupsQueue 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpointsQueue
  name: 'default'
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
  dependsOn: []
}

// Private Endpoint Queue DNS Zone Group
resource privateDnsZoneGroupsTable 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpointsTable
  name: 'default'
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
  dependsOn: []
}

// Deploy Function Apps
resource sites 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: appServicePlan.outputs.serverfarmsId
    publicNetworkAccess: 'Disabled'
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: true
    vnetImagePullEnabled: false
    vnetContentShareEnabled: true
    vnetBackupRestoreEnabled: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts.name};AccountKey=${storageAccounts.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts.name};AccountKey=${storageAccounts.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        // {
        //   name: 'WEBSITE_RUN_FROM_PACKAGE'
        //   value: '1'
        // }
        {
          name: 'vnetRouteAllEnabled'
          value: 'true'
        }
        {
          name: 'vnetContentShareEnabled'
          value: 'true'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: components.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
        {
          name: 'KEYVAULT_URI'
          value: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'
        }
      ]
      netFrameworkVersion: 'v8.0'
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      requestTracingEnabled: false
      remoteDebuggingEnabled: false
      remoteDebuggingVersion: 'VS2022'
      httpLoggingEnabled: false
      logsDirectorySizeLimit: 35
      detailedErrorLoggingEnabled: false
      publishingUsername: '$${functionAppName}'
      scmType: 'None'
      use32BitWorkerProcess: true
      webSocketsEnabled: false
      managedPipelineMode: 'Integrated'
      virtualApplications: [
        {
          virtualPath: '/'
          physicalPath: 'site\\wwwroot'
          preloadEnabled: true
        }
      ]
      loadBalancing: 'LeastRequests'
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: true
    virtualNetworkSubnetId: functionAppSubnetId
    keyVaultReferenceIdentity: userAssignedIdentityId
  }
  dependsOn: [
    appServicePlan
  ]
}

// FTP Publishing Credentials
resource basicPublishingCredentialsPolicies_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites
  name: 'ftp'
  // location: location
  properties: {
    allow: true
  }
}

// SCM Publishing Credentials
resource basicPublishingCredentialsPolicies_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites
  name: 'scm'
  // location: location
  properties: {
    allow: true
  }
}

// Host Binding
resource hostNamesBindings 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: sites
  name: '${functionAppName}.azurewebsites.net'
  properties: {
    siteName: functionAppName
  }
}

// Virtual Network Integration / Network Injection

resource virtualNetworkConnections 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = {
  parent: sites
  name: 'virtualNetworkConnections.${functionAppName}'
  properties: {
    vnetResourceId: functionAppSubnetId
    isSwift: true
  }
}

// Private Endpoints

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${functionAppName}-azurewebsites-pe01'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${functionAppName}-azurewebsites-pe01'
        properties: {
          privateLinkServiceId: sites.id
          groupIds: [
            'sites'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${functionAppName}-azurewebsites-pe-nic01'
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private DNS Zone Groups
resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: privateEndpoints
  name: privateDnsZoneNameWebsites
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.azurewebsites.net-config'
        properties: {
          privateDnsZoneId: privateDnsZoneIdWebsites
        }
      }
    ]
  }
  dependsOn: []
}

// Application Insights
resource components 'microsoft.insights/components@2020-02-02' = {
  name: componentsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output serverfarmsId string = appServicePlan.outputs.serverfarmsId
output systemAssignedIdentityId string = sites.identity.principalId
