targetScope = 'subscription'

param subscriptionId string
param hubSubscriptionId string
param location string

param env string

// Deployment Options
param bypassRoles bool
param bypassFunctionApp bool
param bypassWebApp bool
param bypassAzureSQL bool
param bypassDatalake bool
param bypassUAMI bool
param bypassLogAnalytics bool
param bypassAutomation bool
param bypassKeyVault bool
param bypassVirtualNetwork bool

param productionSKUs bool
param sku object


param dataResourceGroupName string
param dnsResourceGroupName string
param networkResourceGroupName string
param virtualNetworkName string
param endpointSubnetName string
param functionAppSubnetName string

param spokeAddressSpace string
param endpointSubnetCIDR string
param functionAppSubnetCIDR string
param dnsServers array
param nsgRules array

param tags object

// Virtual Network Options. Do not change Parameter Names, only Parameter Values

param pepSubnetId string = '/subscriptions/${subscriptionId}/resourceGroups/${networkResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${endpointSubnetName}'
param functionAppSubnetId string = '/subscriptions/${subscriptionId}/resourceGroups/${networkResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${functionAppSubnetName}'

// Azure Data Lake Services
param adlsName string
param dataLakeStorageDefaultContainerName string = 'default' // Default naming for Default Container
param dataLakeStorageFlatfileContainerName string = 'flatfiles' // Default naming for Flatfile Container
param dataLakeStorageFrameworkContainerName string = 'framework' // Default naming for Framework Container 

// Log Analytics
param logAnalyticsName string

// App Services
param functionAppName string
param webAppName string

// Key Vault
param keyVaultName string
param keyName string

// Automation Account
param automationAccountsName string

// Azure Identity Options
param managedIdentityName string
param dataAdminGroupName string
param devOpsServicePrincipalId string
param dataAdminGroupId string
param dataTeamGroupId string

// Azure SQL
param sqlServerName string
param sqlDatabases array
// param sqlDatabaseName string

param dataLakeSubResourceNames array

// DNS Zone Names
param privateDnsZoneNameAutomation string = 'privatelink.azure-automation.net'
param privateDnsZoneNameKeyVault string = 'privatelink.vaultcore.azure.net'
param privateDnsZoneNameFile string = 'privatelink.file.${environment().suffixes.storage}'
param privateDnsZoneNameBlob string = 'privatelink.blob.${environment().suffixes.storage}'
param privateDnsZoneNameTable string = 'privatelink.table.${environment().suffixes.storage}'
param privateDnsZoneNameQueue string = 'privatelink.queue.${environment().suffixes.storage}'
param privateDnsZoneNameDfs string = 'privatelink.dfs.${environment().suffixes.storage}'
param privateDnsZoneNameSql string = 'privatelink${environment().suffixes.sqlServerHostname}'
param privateDnsZoneNameWebsites string = 'privatelink.azurewebsites.net'

// DNS Zone IDs
param privateDnsZoneIdAutomation string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameAutomation}'
param privateDnsZoneIdKeyVault string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameKeyVault}'
param privateDnsZoneIdFile string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameFile}'
param privateDnsZoneIdBlob string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameBlob}'
param privateDnsZoneIdTable string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameTable}'
param privateDnsZoneIdQueue string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameQueue}'
param privateDnsZoneIdDfs string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameDfs}'
param privateDnsZoneIdSql string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameSql}'
param privateDnsZoneIdWebsites string = '/subscriptions/${hubSubscriptionId}/resourceGroups/${dnsResourceGroupName}/providers/Microsoft.Network/privateDnsZones/${privateDnsZoneNameWebsites}'

param subnets array = [
  // Azure PrivateEndpoint Subnet
  {
    name: endpointSubnetName
    subnetPrefix: endpointSubnetCIDR
  }
  // Virtual Network Integration Subnet
  {
    name: functionAppSubnetName
    subnetPrefix: functionAppSubnetCIDR
  }
]

// resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
//   name: dataResourceGroupName
// }

// Create Virtual Network
module virtualNetwork 'network/virtualNetwork.bicep' = if (bypassVirtualNetwork == false) {
  scope: resourceGroup(networkResourceGroupName)
  name: '${env}-virtualNetwork'
  params: {
    subnets: subnets
    location: location
    spokeAddressSpace: spokeAddressSpace
    virtualNetworkName: virtualNetworkName
    endpointSubnetName: endpointSubnetName
    functionAppSubnetName: functionAppSubnetName
    dnsServers: dnsServers
    nsgRules: nsgRules
    tags: tags
  }
  dependsOn: []
}

// Create User Assigned Managed Identity
module userAssignedIdentity 'identity/managedIdentity.bicep' = if (bypassUAMI == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-userAssignedIdentity'
  params: {
    location: location
    tags: tags
    managedIdentityName: managedIdentityName
  }
  dependsOn: []
}

module rolesResourceGroup 'identity/rolesResourceGroup.bicep' = if (bypassRoles == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-rolesResourceGroup'
  params: {
    devOpsServicePrincipalId: devOpsServicePrincipalId
    userAssignedIdentityPrincipalId: userAssignedIdentity.outputs.userAssignedIdentityPrincipalId
    dataAdminGroupId: dataAdminGroupId
    dataTeamGroupId: dataTeamGroupId
  }
  dependsOn: [
    userAssignedIdentity
  ]
}

// Create Log Analytics Workspace
module logAnalytics 'common/logAnalytics.bicep' = if (bypassLogAnalytics == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-monitoring'
  params: {
    logAnalyticsName: logAnalyticsName
    location: location
  }
  dependsOn: []
}

// Create Automation Account
module automation 'common/automationAccount.bicep' = if (bypassAutomation == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-automation'
  params: {
    automationAccountsName: automationAccountsName
    location: location
    pepSubnetId: pepSubnetId
    privateDnsZoneIdAutomation: privateDnsZoneIdAutomation
    privateDnsZoneNameAutomation: privateDnsZoneNameAutomation
    tags: tags
    managedIdentityName: managedIdentityName
    dataResourceGroupName: dataResourceGroupName
  }
  dependsOn: [
    virtualNetwork
    userAssignedIdentity
  ]
}

// Create Key Vault
module keyVault 'common/keyVault.bicep' = if (bypassKeyVault == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-keyVault'
  params: {
    tenantId: tenant().tenantId
    privateDnsZoneIdKeyVault: privateDnsZoneIdKeyVault
    pepSubnetId: pepSubnetId
    keyVaultName: keyVaultName
    location: location
    tags: tags
    
  }
  dependsOn: [
    virtualNetwork
    userAssignedIdentity
  ]
}

// Call Data Platform
module dataPlatform 'dataplatform.bicep' = {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-dataplatform'
  params: {
    bypassFunctionApp: bypassFunctionApp
    bypassWebApp: bypassWebApp
    bypassAzureSQL: bypassAzureSQL
    bypassDatalake: bypassDatalake
    bypassRoles: bypassRoles
    adlsName: adlsName
    location: location
    tags: tags

    privateDnsZoneIdFile: privateDnsZoneIdFile
    privateDnsZoneIdBlob: privateDnsZoneIdBlob
    privateDnsZoneIdTable: privateDnsZoneIdTable
    privateDnsZoneIdQueue: privateDnsZoneIdQueue
    privateDnsZoneIdDfs: privateDnsZoneIdDfs
    privateDnsZoneIdSql: privateDnsZoneIdSql
    privateDnsZoneIdWebsites: privateDnsZoneIdWebsites
    privateDnsZoneNameBlob: privateDnsZoneNameBlob
    privateDnsZoneNameDfs: privateDnsZoneNameDfs
    privateDnsZoneNameFile: privateDnsZoneNameFile
    privateDnsZoneNameQueue: privateDnsZoneNameQueue
    privateDnsZoneNameTable: privateDnsZoneNameTable
    privateDnsZoneNameSql: privateDnsZoneNameSql
    privateDnsZoneNameWebsites: privateDnsZoneNameWebsites
    
    dataLakeSubResourceNames: dataLakeSubResourceNames
    userAssignedIdentityId: userAssignedIdentity.outputs.userAssignedIdentityId
    dataLakeStorageFrameworkContainerName: dataLakeStorageFrameworkContainerName
    dataLakeStorageFlatfileContainerName: dataLakeStorageFlatfileContainerName
    dataLakeStorageDefaultContainerName: dataLakeStorageDefaultContainerName
    pepSubnetId: pepSubnetId
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsId
    dataResourceGroupName: dataResourceGroupName
    managedIdentityName: managedIdentityName
    dataAdminGroupName: dataAdminGroupName
    dataAdminGroupId: dataAdminGroupId
    keyVaultName: keyVaultName
    keyName: keyName
    sqlDatabases: sqlDatabases
    sqlServerName: sqlServerName
    // sqlDatabaseName: sqlDatabaseName
    functionAppName: functionAppName
    functionAppSubnetId: functionAppSubnetId
    webAppName: webAppName
    env: env
    productionSKUs: productionSKUs
    sku: sku
  }
  dependsOn: [
    virtualNetwork
    userAssignedIdentity
    logAnalytics
    keyVault
  ]
}
