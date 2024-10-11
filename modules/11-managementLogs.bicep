targetScope = 'subscription'

param tags object

// Connectivity Resource Groups Defined in YAML
param managementLogsResourceGroupName string
param CAFPrefix string
param location string


// Connectivity Network Resource Group Name
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: managementLogsResourceGroupName
}

// Log Analytics Workspace for each Subscription
module logAnalyticsWorkspace 'monitoring/logAnalytics.bicep' = {
  scope: resourceGroup
  name: 'subCommonResources.bicep.logAnalyticsWorkspace'
  params: {
    CAFPrefix: CAFPrefix
    location: location
    tags: tags
  }
}
