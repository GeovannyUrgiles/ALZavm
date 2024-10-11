param tags object

param managementLogsResourceGroupName string
param AzurePrivateEndpointSubnetId string
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceId string
param privateDNSZoneId string
param nameSeparator string
param CAFPrefix string
param location string

// Create Automation Account
resource automationAccounts 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: '${CAFPrefix}${nameSeparator}aa'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: true
  }
}

// Log Analytics Workspace for each Subscription
module automationAccountWorkspace 'automationAccountWorkspace.bicep' = {
  scope: resourceGroup(managementLogsResourceGroupName)
  name: 'automationAccountWorkspace'
  params: {
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    automationAccountId: automationAccounts.id
  }
}

// Create Private Endpoint
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2021-08-01' = {
  name: '${automationAccounts.name}${nameSeparator}pe'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${automationAccounts.name}${nameSeparator}pe'
        properties: {
          privateLinkServiceId: automationAccounts.id
          groupIds: [
            'DSCAndHybridWorker'
          ]
        }
      }
    ]
    subnet: {
      id: AzurePrivateEndpointSubnetId
    }
    customNetworkInterfaceName: '${automationAccounts.name}${nameSeparator}nic'
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private DNS Zone Group
resource privateDnsZoneGroupsAgentSvc 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  name: 'privateDnsZoneGroups.AgentSvc'
  parent: privateEndpoints
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'default'
        properties: {
          privateDnsZoneId: privateDNSZoneId
        }
      }
    ]
  }
}

// Add Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-automation'
  scope: automationAccounts
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'JobLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
      {
        category: 'JobStreams'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
      {
        category: 'DscNodeStatus'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 0
        }
      }
    ]
  }
}
