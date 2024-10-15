targetScope = 'subscription'

param tags object

// Resource Groups are defined in YAML
param identityKeyVaultResourceGroupName string
param AzurePrivateEndpointSubnetId string
param logAnalyticsWorkspaceId string
param privateDNSZoneId string
param nameSeparator string
param CAFPrefix string
param location string

// Management Automation Resource Group Name
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: identityKeyVaultResourceGroupName
}

// Automation Account with Private Endpoint
module automationAccount 'identity/keyVault.bicep' = {
  scope: resourceGroup
  name: 'identityKeyVault'
  params: {
    AzurePrivateEndpointSubnetId: AzurePrivateEndpointSubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    privateDNSZoneId: privateDNSZoneId
    nameSeparator: nameSeparator
    CAFPrefix: CAFPrefix
    location: location
    tags: tags
  }
}
