targetScope = 'subscription'

param tags object

param connectivityDNSResourceGroupName string
param virtualNetworkName string
param virtualNetworkId string


// Virtual Network / Privatelink DNS Zones
param privatelinkDnsZoneNames array = [
//  'pbidedicated.windows.net'
//  'botplinks.botframework.com'
//  'bottoken.botframework.com'
//  'privatelinks.aznbcontent.net'
//  'privatelinks.notebooks.azure.net'
//  'privatelink.adf.azure.com'
  'privatelink.azure-automation.net'
  'privatelink.azurecr.io'
  'privatelink.azurewebsites.net'
  'privatelink.azurestaticapps.net'
//  'privatelink.analysis.windows.net'
//  'privatelink.azurehdinsight.net'
//  'privatelink.azure-api.net'
//  'privatelink.azconfig.io'
//  'privatelink.azure-devices.net'
//  'privatelink.azuresynapse.net'
  'privatelink.agentsvc.azure-automation.net'
//  'privatelink.batch.azure.com'
  'privatelink.blob.${environment().suffixes.storage}'
//  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink${environment().suffixes.sqlServerHostname}'
//  'privatelink.datafactory.azure.net'
//  'privatelink.dev.azuresynapse.net'
//  'privatelink.developer.azure-api.net'
  'privatelink.dfs.${environment().suffixes.storage}'
//  'privatelink.digitaltwins.azure.net'
//  'privatelink.documents.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.file.${environment().suffixes.storage}'
//  'privatelink.guestconfiguration.azure.com'
//  'privatelink.his.arc.azure.com'
  'privatelink.monitor.azure.com'
//  'privatelink.mongo.cosmos.azure.com'
//  'privatelink.mysql.database.azure.com'
//  'privatelink.mariadb.database.azure.com'
//  'privatelink.managedhsm.azure.net'
//  'privatelink.media.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
// 'privatelink.postgres.database.azure.com'
//  'privatelink.purview.azure.com'
//  'privatelink.purviewstudio.azure.com'
//  'privatelink.prod.migration.windowsazure.com'
//  'privatelink.pbidedicated.windows.net'
  'privatelink.queue.${environment().suffixes.storage}'
//  'privatelink.redis.cache.windows.net'
//  'privatelink.redisenterprise.cache.azure.net'
//  'privatelink.search.windows.net'
//  'privatelink.service.signalr.net'
//  'privatelink.servicebus.windows.net'
//  'privatelink.sql.azuresynapse.net'
  'privatelink.table.${environment().suffixes.storage}'
//  'privatelink.table.cosmos.azure.com'
//  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.${environment().suffixes.storage}'
//  'privatelink.gremlin.cosmos.azure.com'
]

// connectivity Network Resource Group Name
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: connectivityDNSResourceGroupName
}

// Private DNS Zone Creation
module privateDnsZones 'network/azureDNSPrivateZones.bicep' = {
  scope: resourceGroup
  name: 'subNetworkconnectivity.bicep.privateDnsZones'
  params: {
    tags: tags
    privateDnsZoneNames: privatelinkDnsZoneNames
  }
  dependsOn: []
}

// Private DNS Zone Network Links
module privateDnsLinks 'network/azureDNSPrivateLinks.bicep' = {
  scope: resourceGroup
  name: 'subNetworkconnectivity.bicep.privateDnsLinks'
  params: {
    virtualNetworkId: virtualNetworkId
    virtualNetworkName: virtualNetworkName
    privatelinkDnsZoneNames: privatelinkDnsZoneNames
  }
  dependsOn: [
    privateDnsZones
  ]
}
