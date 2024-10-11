targetScope = 'subscription'

param tags object

// Resource Groups are defined in YAML
param managementAutomationResourceGroupName string
param managementLogsResourceGroupName string
param logAnalyticsWorkspaceId string
param logAnalyticsWorkspaceName string
param AzurePrivateEndpointSubnetId string
param privateDNSZoneId string
param nameSeparator string
param CAFPrefix string
param location string

// Management Automation Resource Group Name
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: managementAutomationResourceGroupName
}

// Automation Account with Private Endpoint
module automationAccount 'automation/automationAccount.bicep' = {
  scope: resourceGroup
  name: 'managementAutomationAccount'
  params: {
    AzurePrivateEndpointSubnetId: AzurePrivateEndpointSubnetId
    managementLogsResourceGroupName: managementLogsResourceGroupName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    privateDNSZoneId: privateDNSZoneId
    nameSeparator: nameSeparator
    CAFPrefix: CAFPrefix
    location: location
    tags: tags
  }
}
