targetScope = 'subscription'

param tags object

param location string
// Connectivity Resource Groups Defined in YAML
param connectivityNetworkResourceGroupName string
param connectivityOpenAIResourceGroupName string
param connectivityDNSResourceGroupName string

// Place Resource Groups into Array for Looping
param connectivityResourceGroupNames array = [
  connectivityNetworkResourceGroupName
  connectivityDNSResourceGroupName
  connectivityOpenAIResourceGroupName
]

// Loop through Connectivity Resource Groups
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for resourceGroupName in connectivityResourceGroupNames: {
  name: resourceGroupName
  location: location
  tags: tags
}]
