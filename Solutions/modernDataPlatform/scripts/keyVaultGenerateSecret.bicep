@secure()
param sqlSecretName string
param keyVaultName string
param location string
param baseTime string = utcNow('u')

var epoch = dateTimeToEpoch(dateTimeAdd(baseTime, 'P1Y'))

// Generate Password - this will create a Deployment Script artifact, the pipeline YML will delete it
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deploymentScript'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '3.0'
    retentionInterval: 'P1D'
    scriptContent: loadTextContent('../../scripts/azure-password.ps1')
  }
}

// Existing Key Vault
resource vaults 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

// Create SQLAdmin Password
resource secretsSQLPassword 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: vaults
  name: sqlSecretName
  properties: {
    value: deploymentScript.properties.outputs.password
    attributes: {
      enabled: true
      exp: epoch
    }
  }
}
