param tags object

param keyVaultName string = '${CAFPrefix}${nameSeparator}kv'
param AzurePrivateEndpointSubnetId string
param logAnalyticsWorkspaceId string
param privateDNSZoneId string
param nameSeparator string
param CAFPrefix string
param location string

// Create Key Vault
resource vaults 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: [
      // {
      //   tenantId: tenantId
      //   objectId: '52eae2b7-ee18-4554-a322-a928bc708532'
      //   permissions: {
      //     keys: [
      //       'Get'
      //       'List'
      //       'Update'
      //       'Create'
      //       'Import'
      //       'Delete'
      //       'Recover'
      //       'Backup'
      //       'Restore'
      //       'GetRotationPolicy'
      //       'SetRotationPolicy'
      //       'Rotate'
      //     ]
      //     secrets: [
      //       'Get'
      //       'List'
      //       'Set'
      //       'Delete'
      //       'Recover'
      //       'Backup'
      //       'Restore'
      //     ]
      //     certificates: [
      //       'Get'
      //       'List'
      //       'Update'
      //       'Create'
      //       'Import'
      //       'Delete'
      //       'Recover'
      //       'Backup'
      //       'Restore'
      //       'ManageContacts'
      //       'ManageIssuers'
      //       'GetIssuers'
      //       'ListIssuers'
      //       'SetIssuers'
      //       'DeleteIssuers'
      //     ]
      //   }
      // }
    ]
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    vaultUri: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'
    publicNetworkAccess: 'Disabled'
  }
}

// Create Private Endpoint
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: '${vaults.name}${nameSeparator}pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}${nameSeparator}pe'
        properties: {
          privateLinkServiceId: vaults.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: AzurePrivateEndpointSubnetId
    }
    customNetworkInterfaceName: '${vaults.name}${nameSeparator}nic'
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private DNS Zone Group
resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: 'privateDNSZoneGroups.vaults'
  parent: privateEndpoints
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDNSZoneId
        }
      }
    ]
  }
}

// Add Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-keyvault'
  scope: vaults
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
    ]
  }
}
