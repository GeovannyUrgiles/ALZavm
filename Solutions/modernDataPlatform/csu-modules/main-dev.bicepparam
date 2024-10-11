using 'main.bicep'

param productionSKUs = false
param bypassVirtualNetwork = false
param bypassRoles = true
param bypassFunctionApp = true
param bypassWebApp = true
param bypassDatalake = true
param bypassAzureSQL = true
param bypassAutomation = true
param bypassKeyVault = true
param bypassLogAnalytics = true
param bypassUAMI = true

param location = 'westus2'
var locationShort = 'wus2'

param subscriptionId = '5fd55dd9-d76e-48b3-86f5-66638a425f9c'
param hubSubscriptionId = '52ee1c04-98f8-4b57-a8e0-374872490778'
param devOpsServicePrincipalId = 'fda647c5-3207-4d37-bc8b-d0a9de04ec04'
param dataAdminGroupName = 'G_C_Data_Analytics_Admins'
param dataAdminGroupId = '89eedcb3-0ba8-43da-b3e9-67cea0c92cc8'
param dataTeamGroupId = '9c8ccf0b-f155-4a8a-a3dd-3684bd0c9d36'

param env = 'dev'
var envShort = 'dev'

param sku = {
  nonprod: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  prod: {
    name: 'P0v3'
    tier: 'Premium0V3'
    size: 'P0v3'
    family: 'Pv3'
    capacity: 1
  }
}

param tags = {
}

param dataResourceGroupName = 'da-${envShort}-${locationShort}-rg'
param networkResourceGroupName = 'da-${envShort}-${locationShort}-rg'
param dnsResourceGroupName =  'hub-network-${locationShort}-rg'
param keyVaultName = 'da-${envShort}-${locationShort}-kv01'
param keyName = '${envShort}AzureDataAnalyticsDataAtRest'
param automationAccountsName = 'da-${envShort}-${locationShort}-aa01'
param managedIdentityName = 'da-${envShort}-${locationShort}-mi01'
param logAnalyticsName = 'da-${envShort}-${locationShort}-law01'
param functionAppName = 'da-${envShort}-${locationShort}-func01'
param webAppName = 'da-${envShort}-${locationShort}-app01'
param adlsName = toLower('da${envShort}${locationShort}adl01')
param dataLakeStorageDefaultContainerName = 'default'
param dataLakeStorageFlatfileContainerName = 'flatfile'
param dataLakeStorageFrameworkContainerName = 'framework'
param dataLakeSubResourceNames = [
  // maintain index order
  'file'
  'blob'
  'table'
  'queue'
  'dfs'
]

param sqlServerName = toLower('da${envShort}${locationShort}sql01')
param sqlDatabases = [
  toLower('fwk-mdp-${env}-${locationShort}-db01')
]

param virtualNetworkName = 'da-${envShort}-${locationShort}-vnet'
param spokeAddressSpace = '10.152.48.0/23'
param endpointSubnetName = 'privateEndpointSN01'
param endpointSubnetCIDR = '10.152.48.0/24'
param functionAppSubnetName = 'functionAppSN01'
param functionAppSubnetCIDR = '10.152.49.0/26'
param dnsServers = [
  '10.152.41.68'
]
param nsgRules = []
