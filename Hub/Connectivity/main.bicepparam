using 'main.bicep'

// Deployment Options

param enableAzureFirewall = true
param enableDnsResolver = true
param enablePrivatDnsZones = true
param enableUserAssignedManagedIdentity = true
param enableVirtualHub = true
param enableVirtualNetwork = true
param enableVirtualNetworkGroup = true
param enableVirtualWan = true
param enableVpnSite = true
param enableBastion = true
param enableFirewall = true
// param enableRecoveryServiceVault = true

// Resource Names

param firewallName = 'tcfirewall'
param firewallPolicyName = 'tcfirewallpol'

// var inboundSubnetName = subnets[2].name
// var outboundSubnetName = subnets[3].name

// param inboundEndpoints = [
//   {
//     name: 'inbound'
//     subnetResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupNetworkName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${inboundSubnetName}'
//   }
// ]
// param outboundEndpoints = [
//   {
//     name: 'outbound'
//     subnetResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupNetworkName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${subnets.name[4]}'
//   }
// ]

param uamiName = 'conwus2mi'
param virtualHubName = 'conwus2hub'
param virtualNetworkName = 'conwus2vnet'
param virtualWanName = 'conwus2vwan'
param defaultRoutesName = 'DefaultRouteTable'
param vpnSiteName = 'conwus2site'
param resourceGroupNetworkName = 'conwus2networkrg'
param resourceGroupBastionName = 'conwus2bastionrg'
param resourceGroupPrivateDnsName = 'conwus2privdnsrg'
param bastionName = 'conwus2bh'
param dnsResolverName = 'conwus2dns'

// Firewall Policy Groups and Rules

param ruleCollectionGroups = [
  {
    name: 'DefaultRuleCollectionGroup'
    properties: {
      ruleCollections: [
        {
          name: 'DefaultRuleCollection'
          properties: {
            rules: '' 
          }
        }
        {
          name: 'NetworkRuleCollection'
          properties: {
            rules: '' 
          }
        }
        {
          name: 'ApplicationRuleCollection'
          properties: {
            rules: '' 
          }
        }
      ]
    }
  }
  // {
  //   name: 'rule-001'
  //   priority: 5000
  //   ruleCollections: [
  //     {
  //       action: {
  //         type: 'Allow'
  //       }
  //       name: 'collection002'
  //       priority: 5555
  //       ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
  //       rules: [
  //         {
  //           destinationAddresses: [
  //             '*'
  //           ]
  //           destinationFqdns: []
  //           destinationIpGroups: []
  //           destinationPorts: [
  //             '80'
  //           ]
  //           ipProtocols: [
  //             'TCP'
  //             'UDP'
  //           ]
  //           name: 'rule002'
  //           ruleType: 'NetworkRule'
  //           sourceAddresses: [
  //             '*'
  //           ]
  //           sourceIpGroups: []
  //         }
  //       ]
  //     }
  //   ]
  // }
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

// Default NSG Rules

param securityRules = [
  {
    name: 'Deny-All-Inbound'
    properties: {
      access: 'Deny'
      destinationAddressPrefix: '*'
      destinationPortRange: '*'
      direction: 'Inbound'
      priority: 4095
      protocol: '*'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
    }
  }
  {
    name: 'Allow-AzureCloud-Tcp'
    properties: {
      access: 'Allow'
      destinationAddressPrefix: 'AzureCloud'
      destinationPortRange: '443'
      direction: 'Outbound'
      priority: 250
      protocol: 'Tcp'
      sourceAddressPrefixes: [
        addressSpace[0]
      ]
      sourcePortRange: '*'
    }
  }
]

// Virtual Network Properties

param addressSpace = [
  '10.0.0.0/16'
]

param subnets = [
  {
    name: 'GatewaySubnet'
    subnetPrefix: '10.0.0.0/24'
  }
  {
    name: 'AzureBastionSubnet'
    subnetPrefix: '10.0.1.0/24'
  }
  {
    name: 'DnsInbound'
    subnetPrefix: '10.0.2.0/24'
  }
  {
    name: 'DnsOutbound'
    subnetPrefix: '10.0.3.0/24'
  }
]

// Role Assignments for Resource Groups

param roleAssignmentsNetwork = [
  {
    // Network Team
    name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    // Security Team
    name: '<name>'
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    // Neudesic Engineering
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]

param roleAssignmentsBastion = [
  {
    // Network Team
    name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    // Security Team
    name: '<name>'
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    // Neudesic Engineering
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]

param roleAssignmentsPrivateDns = [
  {
    // Network Team
    name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    // Security Team
    name: '<name>'
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    // Neudesic Engineering
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]

// Private DNS Zones. Deploy only what's required

param privatelinkDnsZoneNames = [
  'pbidedicated.windows.net'
  'botplinks.botframework.com'
  'bottoken.botframework.com'
  'privatelinks.aznbcontent.net'
  'privatelinks.notebooks.azure.net'
  'privatelink.adf.azure.com'
  'privatelink.azure-automation.net'
  'privatelink.azurecr.io'
  'privatelink.azurewebsites.net'
  'privatelink.azurestaticapps.net'
  'privatelink.analysis.windows.net'
  'privatelink.azurehdinsight.net'
  'privatelink.azure-api.net'
  'privatelink.azconfig.io'
  'privatelink.azure-devices.net'
  'privatelink.azuresynapse.net'
  'privatelink.agentsvc.azure-automation.net'
  'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  'privatelink.cassandra.cosmos.azure.com'
  'privatelink.cognitiveservices.azure.com'
  'privatelink.database.windows.net'
  'privatelink.datafactory.azure.net'
  'privatelink.dev.azuresynapse.net'
  'privatelink.developer.azure-api.net'
  'privatelink.dfs.core.windows.net'
  'privatelink.digitaltwins.azure.net'
  'privatelink.documents.azure.com'
  'privatelink.eventgrid.azure.net'
  'privatelink.file.core.windows.net'
  'privatelink.guestconfiguration.azure.com'
  'privatelink.his.arc.azure.com'
  'privatelink.monitor.azure.com'
  'privatelink.mongo.cosmos.azure.com'
  'privatelink.mysql.database.azure.com'
  'privatelink.mariadb.database.azure.com'
  'privatelink.managedhsm.azure.net'
  'privatelink.media.azure.net'
  'privatelink.ods.opinsights.azure.com'
  'privatelink.oms.opinsights.azure.com'
  'privatelink.postgres.database.azure.com'
  'privatelink.purview.azure.com'
  'privatelink.purviewstudio.azure.com'
  'privatelink.prod.migration.windowsazure.com'
  'privatelink.pbidedicated.windows.net'
  'privatelink.queue.core.windows.net'
  'privatelink.redis.cache.windows.net'
  'privatelink.redisenterprise.cache.azure.net'
  'privatelink.search.windows.net'
  'privatelink.service.signalr.net'
  'privatelink.servicebus.windows.net'
  'privatelink.sql.azuresynapse.net'
  'privatelink.table.core.windows.net'
  'privatelink.table.cosmos.azure.com'
  'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  'privatelink.gremlin.cosmos.azure.com'
]

// VWAN Properties

param virtualWanSku = 'Standard'

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
param enableTunneling = true




param firewallTier = 'Standard'

// param hubRoutingPreference = 'None'

param location = 'westus2'
param primaryRegionName = 'westus2'
param secondaryRegionName = 'eastus2'

param numberOfPublicIPs = 1

// param onPremDnsServer = ''

// param preferredRoutingGateway = ''

param privateIPAllocationMethod = 'Dynamic'

param scaleUnits = 1

param subscriptionId = ''

// Default Tags

param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}

// Resource Group Lock

param lock = {
  kind: 'CanNotDelete'
  name: 'ProtectedResource'
}

// param vpnGatewayScaleUnit = 1
