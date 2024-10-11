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

// Resource Names

param firewallName = 'tcfirewall'
param firewallPolicyName = 'tcfirewallpol'
param inboundEndpoints = 'subnetin'
param outboundEndpoints = 'subnetout'
param uamiName = 'uami'
param virtualHubName = 'vwanhub'
param virtualNetworkName = 'vnet'
param virtualWanName = 'vwan'
param defaultRoutesName = 'DefaultRouteTable'
param vpnSiteName = 'vpnSite'
param resourceGroupNetworkName = 'resourceGroupNetwork'
param bastionName = 'bastion'
param dnsResolverName = 'dnsResolver'

// Firewall Policy Groups and Rules

param ruleCollectionGroups = [
  {
    name: 'DefaultRuleCollectionGroup'
    properties: {
      ruleCollections: [
        {
          name: 'DefaultRuleCollection'
          properties: {
            rules: securityRules
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
    name: 'AzureBastionSubnet'
    subnetPrefix: '10.1.0.0/24'
  }
]

// Role Assignments for Resource Groups

param roleAssignments = [
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

// Private DNS Zones - Deploy only what's required

param privatelinkDnsZoneNames = [
  // Index:
  'pbidedicated.windows.net' // 01
  'botplinks.botframework.com' // 02
  'bottoken.botframework.com' // 03
  'privatelinks.aznbcontent.net' // 04
  'privatelinks.notebooks.azure.net' // 05
  'privatelink.adf.azure.com' // 06
  'privatelink.azure-automation.net' // 07
  'privatelink.azurecr.io' // 08
  'privatelink.azurewebsites.net' // 09
  'privatelink.azurestaticapps.net' // 11
  'privatelink.analysis.windows.net' // 12
  'privatelink.azurehdinsight.net' // 13
  'privatelink.azure-api.net' // 14
  'privatelink.azconfig.io' // 15
  'privatelink.azure-devices.net' // 16
  'privatelink.azuresynapse.net' // 17
  'privatelink.agentsvc.azure-automation.net' // 18
  'privatelink.batch.azure.com' // 19
  'privatelink.blob.core.windows.net' // 20
  'privatelink.cassandra.cosmos.azure.com' // 21
  'privatelink.cognitiveservices.azure.com' // 22
  'privatelink.database.windows.net' // 23
  'privatelink.datafactory.azure.net' // 24
  'privatelink.dev.azuresynapse.net' // 25
  'privatelink.developer.azure-api.net' // 26
  'privatelink.dfs.core.windows.net' // 27
  'privatelink.digitaltwins.azure.net' // 28
  'privatelink.documents.azure.com' // 29
  'privatelink.eventgrid.azure.net' // 30
  'privatelink.file.core.windows.net' // 31
  'privatelink.guestconfiguration.azure.com' // 32
  'privatelink.his.arc.azure.com' // 33
  'privatelink.monitor.azure.com' // 34
  'privatelink.mongo.cosmos.azure.com' // 35
  'privatelink.mysql.database.azure.com' // 36
  'privatelink.mariadb.database.azure.com' // 37
  'privatelink.managedhsm.azure.net' // 38
  'privatelink.media.azure.net' // 40
  'privatelink.ods.opinsights.azure.com' // 42
  'privatelink.oms.opinsights.azure.com' // 43
  'privatelink.postgres.database.azure.com' // 44
  'privatelink.purview.azure.com' // 45
  'privatelink.purviewstudio.azure.com' // 46
  'privatelink.prod.migration.windowsazure.com' // 47
  'privatelink.pbidedicated.windows.net' // 48
  'privatelink.queue.core.windows.net' // 50
  'privatelink.redis.cache.windows.net' // 51
  'privatelink.redisenterprise.cache.azure.net' // 52
  'privatelink.search.windows.net' // 54
  'privatelink.service.signalr.net' // 55
  'privatelink.servicebus.windows.net' // 56
  'privatelink.sql.azuresynapse.net' // 57
  'privatelink.table.core.windows.net' // 58
  'privatelink.table.cosmos.azure.com' // 59
  'privatelink.tip1.powerquery.microsoft.com' // 60
  'privatelink.vaultcore.azure.net' // 61
  'privatelink.web.core.windows.net' // 62
  'privatelink.gremlin.cosmos.azure.com' // 63
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

// param enableRecoveryServiceVault = true
// param enableVPNGateway = true

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


