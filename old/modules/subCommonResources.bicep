
targetScope = 'subscription'

param tenantId string
param spokeCAFPrefixes string
param spokeCIDRPrefixes string
param location string
param tags object
param pepSubnetId string
param enableRecoveryServiceVault bool
param privateDNSZoneNameAutomation string
param privateDNSZoneNameKeyVault string
param privateDNSZoneNameStorageBlob string
param privateDNSZoneNameStorageFile string
param privateDNSZoneNameStorageTable string
param privateDNSZoneNameStorageQueue string

// Resource Group

resource resourceGroupShared 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${spokeCAFPrefixes}sharedrg'
  location: location
  tags: tags
  dependsOn: []
}

// Automation Account for each Subsciption

module automationAccount 'shared/automationAccount.bicep' = {
  scope: resourceGroupShared
  name: 'subCommonResources.bicep.automationAccount'
  params: {
    spokeCAFPrefixes: spokeCAFPrefixes
    privateDNSZoneNameAutomation: privateDNSZoneNameAutomation
    pepSubnetId: pepSubnetId
    location: location
    tags: tags
  }
}

// Recovery Services Vault

module recoveryServicesVault 'shared/recoveryServicesVault.bicep' = if (enableRecoveryServiceVault == true) : {
  scope: resourceGroupShared
  name: 'subCommonResources.bicep.recoveryServiceVault'
  params: {
    spokeCAFPrefixes: spokeCAFPrefixes
    location: location
    tags: tags
  }
}

// Keyvault / Use Existing Key Vault for the Subscription

/*
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
  scope: resourceGroup(sharedServicesRG)
}
*/

// Key Vault for each Subscription

module keyVaultSpoke 'shared/keyVault.bicep' = {

  scope: resourceGroupShared
  name: 'subCommonResources.bicep.keyVaultSpoke'
  params: {
    spokeCAFPrefixes: spokeCAFPrefixes
    privateDNSZoneNameKeyVault: privateDNSZoneNameKeyVault
    pepSubnetId: pepSubnetId
    location: location
    tags: tags
    tenantId: tenantId
  }
  dependsOn: []
}

// Log Analytics Workspace for each Subscription

module logAnalyticsWorkspace 'shared/logAnalytics.bicep' = {
  scope: resourceGroupShared
  name: 'subCommonResources.bicep.logAnalyticsWorkspace'
  params: {
    spokeCAFPrefixes: spokeCAFPrefixes
    location: location
    automationAccountId: automationAccount.outputs.automationAccountId
    tags: tags
  }
  dependsOn: []
}

// Diagnostics Storage for each Subscription

module diagStorageAccount 'storage/storageAccountDiagnostics.bicep' = {
  scope: resourceGroupShared
  name: 'subCommonResources.bicep.diagStorageAccount'
  params: {
    privateDNSZoneNameStorageBlob: privateDNSZoneNameStorageBlob
    spokeCAFPrefixes: spokeCAFPrefixes
    pepSubnetId: pepSubnetId
    location: location
    tags: tags
  }
  dependsOn: [
  ]
}

output automationAccountId string = automationAccount.outputs.automationAccountId
output automationAccountName string = automationAccount.outputs.automationAccountName
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.outputs.logAnalyticsId
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.outputs.logAnalyticsName

