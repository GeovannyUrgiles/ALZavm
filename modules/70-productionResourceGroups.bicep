targetScope = 'subscription'

param tags object

// Production Resource Groups Defined in YAML
param managementAutomationResourceGroupName string
param managementLogsResourceGroupName string
// Place into Array for Looping
param resourceGroupNames array = [
  managementAutomationResourceGroupName
  managementLogsResourceGroupName
]
param location string


// Loop through Core Resource Groups
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = [for resourceGroupName in resourceGroupNames: {
  name: resourceGroupName
  location: location
  tags: tags

}]
