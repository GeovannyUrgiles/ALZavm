using 'main.bicep'

// Deployment Options

param enableAzureFirewall = true
param enableDnsResolver = false
param enablePrivatDnsZones = true
param enableUserAssignedManagedIdentity = true
param enableVirtualHub = true
param enableVirtualNetwork = true
param enableVirtualNetworkGroup = true
param enableVirtualWan = true
param enableVpnSite = false
param enableBastion = false
param enableFirewall = false
// param enableRecoveryServiceVault = true

// Paired Regions
param location = [
  'westus2' // Primary Region
  'eastus2' // Secondary Region
]

// Resource Names

param firewallName = 'conwus2azfw'
param firewallPolicyName = 'conwus2azfwpol'
param uamiName = 'conwus2mi'
param virtualHubName = 'conwus2hub'
param virtualNetworkName = 'conwus2vnet'
param virtualWanName = 'conwus2vwan'
param defaultRoutesName = 'Default' // Default | None
param vpnSiteName = 'conwus2site'
param resourceGroupName_Network = 'conwus2networkrg'
param resourceGroupName_Bastion = 'conwus2bastionrg'
param resourceGroupName_PrivateDns = 'conwus2dnsrg'
param bastionName = 'conwus2bh'
param dnsResolverName = 'conwus2dns'

// Firewall Policy Groups and Rules

param ruleCollectionGroups = [
  {
    ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
    action: {
      type: 'Allow'
    }
    rules: []
    name: 'DefaultCollection'
    priority: 1000
  }
  {
    ruleCollectionType: 'FirewallPolicyNatRuleCollection'
    action: {
      type: 'DNAT'
    }
    rules: []
    name: 'DefaultNatCollection'
    priority: 1000
  }
]

// Site-to-Site VPN Links

param vpnSiteLinks = [
  {
    name: 'Datacenter1'
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
    name: 'Datacenter2'
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

param skuName = 'Standard' // Standard | Premium

param tier = 'Standard' // Standard | Premium
param mode = 'Off' // Alert' | 'Deny'

// Default NSG Rules

param securityRules = []

// Virtual WAN Properties

param addressPrefix = '10.0.0.0/23'

// Virtual Network Properties

param addressPrefixes = [
  '10.1.0.0/18'
]

param subnets = [
  {
    addressPrefix: '10.1.0.0/24'
    name: 'GatewaySubnet'
  }
  {
    addressPrefix: '10.1.1.0/24'
    name: 'AzureBastionSubnet'
    // delegation: 'Microsoft.Network/azureBastionSubnet'
  }
  {
    addressPrefix: '10.1.2.0/24'
    name: 'DnsInbound'
    delegation: 'Microsoft.Network/dnsResolvers'
  }
  {
    addressPrefix: '10.1.3.0/24'
    name: 'DnsOutbound'
    delegation: 'Microsoft.Network/dnsResolvers'
    // networkSecurityGroupResourceId: 'Microsoft.Network/networkSecurityGroups/MyNSG'
  }
]

// Spoke Virtual Networks for Hub Virtual Network Connections

param spokes = [
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

// VWAN Properties

param virtualWanSku = 'Standard' // Basic | Standard | Premium

// VWAN Hub Properties

param allowBranchToBranchTraffic = true /*TODO*/
param allowVnetToVnetTraffic = true /*TODO*/

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

param numberOfPublicIPs = 1

// param onPremDnsServer = ''
// param preferredRoutingGateway = ''

param subscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// Default Tags

param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'v1.0.0'
  Role: 'DeploymentValidation'
}

// Resource Group Lock

param lock = {
  kind: 'CanNotDelete'
  name: 'ProtectedResource'
}

// param vpnGatewayScaleUnit = 1
