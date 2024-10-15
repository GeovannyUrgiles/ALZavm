targetScope = 'subscription'

param tags object

// Resource Groups are defined in YAML
param identityKeyVaultResourceGroupName string
param nameSeparator string
param CAFPrefix string
param location string

// Management Automation Resource Group Name
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: identityKeyVaultResourceGroupName
}

// Automation Account with Private Endpoint
module automationAccount 'identity/managedIdentity.bicep' = {
  scope: resourceGroup
  name: 'identityManagedIdentity'
  params: {
    nameSeparator: nameSeparator
    CAFPrefix: CAFPrefix
    location: location
    tags: tags
  }
}
