param sqlServerName string
param keyVaultName string
param keyName string
param keyVersion string
param keyUri string
param autoRotationEnabled bool

// Reference existing SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: sqlServerName
}

// Create sql server key from key vault
resource sqlServerKey 'Microsoft.Sql/servers/keys@2023-08-01-preview' = {
  name: '${keyVaultName}_${keyName}_${keyVersion}'
  parent: sqlServer
  properties: {
    serverKeyType: 'AzureKeyVault'
    uri: keyUri
  }
}

// Create the encryption protector
resource encryptionProtector 'Microsoft.Sql/servers/encryptionProtector@2023-08-01-preview' = {
  name: 'current'
  parent: sqlServer
  properties: {
    serverKeyType: 'AzureKeyVault'
    serverKeyName: sqlServerKey.name
    autoRotationEnabled: autoRotationEnabled
  }
}
