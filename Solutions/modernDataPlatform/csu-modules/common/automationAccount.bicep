param automationAccountsName string
param location string
param tags object
param pepSubnetId string
param privateDnsZoneIdAutomation string
param privateDnsZoneNameAutomation string
param managedIdentityName string
param dataResourceGroupName string

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(dataResourceGroupName)
  name: managedIdentityName
}

resource automationAccounts 'Microsoft.Automation/automationAccounts@2023-11-01' = {
  name: automationAccountsName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentity.id}': {}
    }
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: false
  }
  dependsOn: []
}

// Create Private Endpoints
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${automationAccountsName}-pe01'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${automationAccountsName}-pe01'
        properties: {
          privateLinkServiceId: automationAccounts.id
          groupIds: [
            'DSCAndHybridWorker'
          ]
        }
      }
    ]
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${automationAccountsName}-nic01'
    ipConfigurations: []
    customDnsConfigs: []
  }
  dependsOn: []
}

// Private DNS Zone Groups
resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'dns-automation'
  parent: privateEndpoints
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameAutomation
        properties: {
          privateDnsZoneId: privateDnsZoneIdAutomation
        }
      }
    ]
  }
  dependsOn: [
  ]
}

output automationAccountName string = automationAccounts.name
output automationAccountId string = automationAccounts.id
