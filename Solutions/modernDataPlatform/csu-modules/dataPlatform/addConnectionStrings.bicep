param keyVaultName string
param storageAccountName string
param sqlDatabases array
param env string
param sqlServerName string
param baseTime string = utcNow('u')
param expiration int = dateTimeToEpoch(dateTimeAdd(baseTime, 'P1Y'))

// Reference existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
}

// Reference existing Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// Create Framework Connection String
resource frameworkConnectionString 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'FrameworkConnectionString'
  properties: {
    value: 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=fwk-mdp-${env}-wus2-db01;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity'
    attributes: {
      enabled: true
      exp: expiration
    }
  }
}

// Create Storage Account Connection String // alternate name could be DataLakeConnectionString
resource storageAccountConnectionString 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'StorageAccountConnectionString'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    attributes: {
      enabled: true
      exp: expiration
    }
  }
}

// Create Storage Account Connection String // alternate name could be DataLakeConnectionString
resource frameworkDatabaseName 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'FrameworkDatabaseName'
  properties: {
    value: sqlDatabases[0] 
    attributes: {
      enabled: true
      exp: expiration
    }
  }
}

// Create Storage Account Connection String // alternate name could be DataLakeConnectionString
resource frameworkDatabaseServer 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'FrameworkDatabaseServer'
  properties: {
    value: '${sqlServerName}${environment().suffixes.sqlServerHostname}'
    attributes: {
      enabled: true
      exp: expiration
    }
  }
}

// Create Storage Account Connection String // alternate name could be DataLakeConnectionString
resource lakehouseConnectionString 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  parent: keyVault
  name: 'LakehouseConnectionString'
  properties: {
    value: storageAccount.listKeys().keys[0].value
    attributes: {
      enabled: true
      exp: expiration
    }
  }
}
