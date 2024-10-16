using 'main.bicep'

// Version

var version = 'v1.0.0'

// Deployment Options

param enableUserAssignedManagedIdentity = true
param enableVirtualNetwork = true
param enableNetworkSecurityGroups = true
param enableDnsResolver = false
param enablePrivatDnsZones = true
param enableVirtualWan = false
param enableVirtualHub = false
param enableVpnGateway = false
param enableVpnSite = false
param enableAzureFirewall = false
param enableBastion = false
param enableOperationalInsightsName = true
// param enableRecoveryServiceVault = true

// Paired Regions

param location = [
  'westus2' // Primary Region
  'eastus2' // Secondary Region
]

// Resource Names

param resourceGroupName_Network = 'conwus2networkrg'
param resourceGroupName_Bastion = 'conwus2bastionrg'
param resourceGroupName_PrivateDns = 'conwus2dnsrg'
param uamiName = 'conwus2mi'
param virtualNetworkName = 'conwus2vnet'
param virtualWanName = 'conwus2vwan'
param virtualHubName = 'conwus2hub'
param vpnSiteName = 'conwus2vpnsite'
param vpnGatewayName = 'conwus2vpngw'
param firewallName = 'conwus2azfw'
param firewallPolicyName = 'conwus2azfwpol'
param bastionName = 'conwus2bh'
param dnsResolverName = 'conwus2dns'
param operationalInsightsName = 'conwus2oi'
param nsgSuffix = '-nsg'
// param nicSuffix = '-nic'

// Default Tags

param tags = {
  Environment: 'Non-Prod'
  'hidden-title': version
  Role: 'DeploymentValidation'
}

// Resource Group Lock

param lock = {
  kind: 'CanNotDelete'
  name: 'ProtectedResource'
}

// Firewall Policy Groups and Rules

param ruleCollectionGroups = [
  {
    name: 'DefaultNetworkRuleCollectionGroup'
    priority: 5000
    ruleCollections: [
      {
        action: {
          type: 'Allow'
        }
        name: 'collection002'
        priority: 5555
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: []
      }
    ]
  }
]

// VPN Site Links

param vpnSiteLinks = [
  {
    name: 'Country1'
    properties: {
      bgpProperties: {
        asn: 65010
        bgpPeeringAddress: '1.1.1.1'
      }
      ipAddress: '1.2.3.4'
      linkProperties: {
        linkProviderName: 'customerName'
        linkSpeedInMbps: 5
      }
    }
  }
  {
    name: 'Acquisition2'
    properties: {
      bgpProperties: {
        asn: 65020
        bgpPeeringAddress: '2.2.2.2'
      }
      ipAddress: '5.6.7.8'
      linkProperties: {
        linkProviderName: 'customerName'
        linkSpeedInMbps: 5
      }
    }
  }
]

// Azure Firewall Properties

@allowed([
  'Standard'
  'Premium'
])

param skuName = 'Standard'
@allowed([
  'Standard'
  'Premium'
])
param tier = 'Standard'

@allowed([
  'Alert'
  'Deny'
  'Off'
])
param mode = 'Off'
param numberOfPublicIPs = 1

// Virtual Network Properties

param virtualNetwork = {
  name: virtualNetworkName
  prefixes: [
    '10.1.0.0/18'
  ]
  subnets: [
    {
      name: 'AzureBastionSubnet'
      addressPrefix: '10.1.0.0/24'
      delegation: ''
      networkSecurityGroupResourceId: ''
    }
    {
      name: toLower('${virtualNetworkName}-PrivateEndpointSn')
      addressPrefix: '10.1.1.0/24'
      delegation: ''
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-PrivateEndpointSn-nsg')
    }
    {
      name: toLower('${virtualNetworkName}-DnsInboundSn')
      addressPrefix: '10.1.2.0/24'
      delegation: 'Microsoft.Network/dnsResolvers'
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-DnsInboundSn-nsg')
    }
    {
      name: toLower('${virtualNetworkName}-DnsOutboundSn')
      addressPrefix: '10.1.3.0/24'
      delegation: 'Microsoft.Network/dnsResolvers'
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-DnsOutboundSn-nsg')
    }
  ]
}

// Default NSG Rules

param securityRules = []

// Virtual WAN Properties

param addressPrefix = '10.0.0.0/23'
param virtualWanSku = 'Standard'
param defaultRoutesName = 'Default' // Default | None

// VWAN Hub Properties

param allowBranchToBranchTraffic = true
param allowVnetToVnetTraffic = true

// Spoke Virtual Networks for Hub Virtual Network Connections

param spokes = [
  {
    subscriptionId: '82d21ec8-4b6a-4bf0-9716-96b38d9abb43'
    resourceGroupName: 'conwus2spokerg'
    virtualNetworkName: 'conwus2spokevnet'
  }
  {
    subscriptionId: '82d21ec8-4b6a-4bf0-9716-96b38d9abb43'
    resourceGroupName: 'conwus2spokerg'
    virtualNetworkName: 'conwus2spokevnet'
  }
]

// Role Assignments for Resource Groups

param roleAssignmentsNetwork = [
  // {
  //   // Network Team
  //   name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'Owner'
  // }
  // {
  //   // Security Team
  //   name: '<name>'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // }
  // {
  //   // Neudesic Engineering
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  // }
]

param roleAssignmentsBastion = [
  // {
  //   // Network Team
  //   name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'Owner'
  // }
  // {
  //   // Security Team
  //   name: '<name>'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // }
  // {
  //   // Neudesic Engineering
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  // }
]

param roleAssignmentsPrivateDns = [
  // {
  //   // Network Team
  //   name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'Owner'
  // }
  // {
  //   // Security Team
  //   name: '<name>'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // }
  // {
  //   // Neudesic Engineering
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  // }
]

// Private DNS Zones. This is not a complete list. Deploy only what's required

param privatelinkDnsZoneNames = [
  //'pbidedicated.windows.net'
  //'botplinks.botframework.com'
  // 'bottoken.botframework.com'
  // 'privatelinks.aznbcontent.net'
  // 'privatelinks.notebooks.azure.net'
  // 'privatelink.adf.azure.com'
  // 'privatelink.azure-automation.net'
  // 'privatelink.azurecr.io'
  // 'privatelink.azurewebsites.net'
  // 'privatelink.azurestaticapps.net'
  // 'privatelink.analysis.windows.net'
  // 'privatelink.azurehdinsight.net'
  // 'privatelink.azure-api.net'
  // 'privatelink.azconfig.io'
  // 'privatelink.azure-devices.net'
  // 'privatelink.azuresynapse.net'
  // 'privatelink.agentsvc.azure-automation.net'
  // 'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  // 'privatelink.cassandra.cosmos.azure.com'
  // 'privatelink.cognitiveservices.azure.com'
  // 'privatelink.database.windows.net'
  // 'privatelink.datafactory.azure.net'
  // 'privatelink.dev.azuresynapse.net'
  // 'privatelink.developer.azure-api.net'
  // 'privatelink.dfs.core.windows.net'
  // 'privatelink.digitaltwins.azure.net'
  // 'privatelink.documents.azure.com'
  // 'privatelink.eventgrid.azure.net'
  'privatelink.file.core.windows.net'
  // 'privatelink.guestconfiguration.azure.com'
  // 'privatelink.his.arc.azure.com'
  'privatelink.monitor.azure.com'
  // 'privatelink.mongo.cosmos.azure.com'
  // 'privatelink.mysql.database.azure.com'
  // 'privatelink.mariadb.database.azure.com'
  // 'privatelink.managedhsm.azure.net'
  // 'privatelink.media.azure.net'
  // 'privatelink.ods.opinsights.azure.com'
  // 'privatelink.oms.opinsights.azure.com'
  // 'privatelink.postgres.database.azure.com'
  // 'privatelink.purview.azure.com'
  // 'privatelink.purviewstudio.azure.com'
  // 'privatelink.prod.migration.windowsazure.com'
  // 'privatelink.pbidedicated.windows.net'
  // 'privatelink.queue.core.windows.net'
  // 'privatelink.redis.cache.windows.net'
  // 'privatelink.redisenterprise.cache.azure.net'
  // 'privatelink.search.windows.net'
  // 'privatelink.service.signalr.net'
  // 'privatelink.servicebus.windows.net'
  // 'privatelink.sql.azuresynapse.net'
  // 'privatelink.table.core.windows.net'
  // 'privatelink.table.cosmos.azure.com'
  // 'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.vaultcore.azure.net'
  // 'privatelink.web.core.windows.net'
  // 'privatelink.gremlin.cosmos.azure.com'
]

// Azure Bastion Properties

param disableCopyPaste = true
param disableVpnEncryption = true
param dnsFirewallProxy = []
param dnsPrivateResolver = []
param enableFileCopy = true
param enableIpConnect = true
param enableShareableLink = true
param scaleUnits = 2

// param enableTunneling = true
// param hubRoutingPreference = 'None'

// param onPremDnsServer = ''
// param preferredRoutingGateway = ''

param subscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// param vpnGatewayScaleUnit = 1
