param keyVaultName string
param tenantId string
param location string
param tags object
param pepSubnetId string
param privateDnsZoneIdKeyVault string
param baseTime string = utcNow('u')
param expiration int = dateTimeToEpoch(dateTimeAdd(baseTime, 'P1Y'))

// Create Key Vault
resource vaults 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: []
    }
    tenantId: tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
    enableRbacAuthorization: true
    vaultUri: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'
    publicNetworkAccess: 'Disabled'
  }
}

// Create Private Endpoint
resource privateendpoints 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${keyVaultName}-pe01'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}-pe01'
        properties: {
          privateLinkServiceId: vaults.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${keyVaultName}-nic01'
    ipConfigurations: []
    customDnsConfigs: []
  }
  dependsOn: []
}

// Private DNS Zone Groups / Vault
resource privatednszonegroupsvaultCore 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'dns-keyvault'
  parent: privateendpoints
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDnsZoneIdKeyVault
        }
      }
    ]
  }
}

output keyVaultName string = vaults.name
output keyVaultId string = vaults.id
output iso string = dateTimeAdd(baseTime, 'P1Y')
output epoch int = expiration
