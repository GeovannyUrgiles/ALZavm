targetScope = 'subscription'

param tags object

// Identity Resource Groups Defined in YAML
param identityActiveDirectoryResourceGroupName string
param identityKeyVaultResourceGroupName string
// Place into Array for Looping
param resourceGroupNames array = [
  identityActiveDirectoryResourceGroupName
  identityKeyVaultResourceGroupName
]
param location string

// Loop through Core Resource Groups
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for resourceGroupName in resourceGroupNames: {
  name: resourceGroupName
  location: location
  tags: tags
}]
