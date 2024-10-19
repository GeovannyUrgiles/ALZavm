using 'main.bicep'

// Version

var version = 'v1.0.0'

// Deployment Options

param enableUserAssignedManagedIdentity = false
param enableVirtualNetwork = true
param enableNetworkSecurityGroups = true
param enableDnsResolver = false
param enablePrivateDnsZones = true
param enableVirtualWan = false
param enableVirtualHub = false
param enableVpnSite = false
param enableVpnGateway = false
param enableAzureFirewall = false
param enableBastion = false
param enableOperationalInsights = true
param enableKeyVault = true
// param enableRecoveryServiceVault = true

// Subscription(s)

param subscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// Paired Regions

param locations = [
  'westus2' // Primary Region
  'eastus2' // Secondary Region
]

param locationsShort = [
  'wus2' // Primary Region
  'eus2' // Secondary Region
]

// Resource Names

param resourceGroupName_Network = [
  'conwus2networkrg'
  'coneus2networkrg'
]
param resourceGroupName_Bastion = [
  'conwus2bastionrg'
  'coneus2bastionrg'
]
param resourceGroupName_PrivateDns = [
  'conwus2dnsrg'
  'coneus2dnsrg'
]

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
param operationalInsightsName = 'conwus2oiw'
param keyVaultName = 'conwus2kv'
param publicIpAddressName01 = 'conwus2pip01'

// Key Vault Properties

param enablePurgeProtection = true
param enableRbacAuthorization = true
param peSuffix = '${nameSeparator}pe'
param nicSuffix = '${nameSeparator}nic'
param nameSeparator = '-'


// Default Tags

param tags = {
  Environment: 'Non-Prod'
  'hidden-title': version
  Role: 'DeploymentValidation'
}

// Resource Group Lock

param lock = {
  delete: {
  name: 'Do Not Delete'
  kind: 'CanNotDelete'
  }
  readonly: {
  name: 'Read Only'
  kind: 'ReadOnly'
  }
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
        name: 'DefaultNetworkRuleCollection'
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
    name: 'dataCenter1' // Data Center or other Remote Site Name
    id: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/vpnSites/${vpnSiteName}/vpnSiteLinks/dataCenter1'
    properties: {
      vpnLinkConnectionMode: 'Default' // Default | HighPerformance
      bgpProperties: {
        asn: 65010 // BGP Autonomous System Number
        bgpPeeringAddress: '10.10.10.1' // Remote BGP Peer IP Address
      }
      ipAddress: '1.2.3.4' // Remote VPN Gateway IP Address or FQDN
      linkProperties: {
        linkProviderName: 'Verizon' // Verizon | ATT | BT | Orange | Vodafone
        linkSpeedInMbps: 100 // 5 | 10 | 20 | 50 | 100 | 200 | 500 | 1000 | 2000 | 5000 | 10000
        // vendor: 'Cisco' // Cisco | Juniper | Microsoft | PaloAlto | Fortinet | CheckPoint | SonicWall | Barracuda | F5 | Citrix | Zscaler | Other
      }
    }
  }
  {
    name: 'dataCenter2' // Data Center or other Remote Site Name
    id: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/vpnSites/${vpnSiteName}/vpnSiteLinks/dataCenter2'
    properties: {
      vpnLinkConnectionMode: 'Default' // Default | HighPerformance
      bgpProperties: {
        asn: 65020 // BGP Autonomous System Number
        bgpPeeringAddress: '10.20.20.1' // Remote BGP Peer IP Address
      }
      ipAddress: '1.2.3.5' // Remote VPN Gateway IP Address or FQDN
      linkProperties: {
        linkProviderName: 'ATT' // Verizon | ATT | BT | Orange | Vodafone
        linkSpeedInMbps: 100 // 5 | 10 | 20 | 50 | 100 | 200 | 500 | 1000 | 2000 | 5000 | 10000
        // vendor: 'Cisco' // Cisco | Juniper | Microsoft | PaloAlto | Fortinet | CheckPoint | SonicWall | Barracuda | F5 | Citrix | Zscaler | Other
      }
    }
  }
]

// VPN Site-to-Site Connections

param vpnConnections = [
  {
    name: 'Connection1' // Connection Name
    connectionBandwidth: 100 // 100 | 200 | 500 | 1000 | 2000 | 5000 | 10000
    enableBgp: false
    enableInternetSecurity: true
    enableRateLimiting: false
    routingWeight: 0
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    vpnConnectionProtocolType: 'IKEv2' // IKEv2 | IKEv1
    vpnLinkConnectionMode: 'Default' // Default | HighPerformance
    sharedKey: 'Passw0rd!'
    dpdTimeoutSeconds: 0
    vpnGatewayCustomBgpAddresses: []
    ipsecPolicies: [
      {
        saDataSizeKilobytes: 1024000 // 1024000 | 102400 | 51200 | 30720 | 20480 | 10240 | 5120 | 2048 | 1024 | 512 | 256 | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1
        saLifeTimeSeconds: 27000 // 27000 | 14400 | 28800 | 3600 | 10800 | 7200 | 4800 | 3600 | 2880 | 2400 | 1440 | 1200 | 720 | 480 | 360 | 240 | 180 | 120 | 60 | 30
        ipsecEncryption: 'AES256' // AES256 | AES128 | DES3 | DES | DES2
        ipsecIntegrity: 'SHA256' // SHA256 | SHA1 | MD5
        ikeEncryption: 'AES256' // AES256 | AES192 | AES128 | DES3 | DES | DES2
        ikeIntegrity: 'SHA256' // SHA256 | SHA1 | MD5
        dhGroup: 'DHGroup24' // DHGroup24 | DHGroup2 | DHGroup14 | DHGroup1 | ECP384 | ECP256
        pfsGroup: 'PFS24' // PFS24 | PFS2 | PFS14 | PFS1
      }
    ]
  }
  {
    name: 'Connection2' // Connection Name
    connectionBandwidth: 100 // 100 | 200 | 500 | 1000 | 2000 | 5000 | 10000
    enableBgp: false
    enableInternetSecurity: true
    enableRateLimiting: false
    routingWeight: 0
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    vpnConnectionProtocolType: 'IKEv2' // IKEv2 | IKEv1
    vpnLinkConnectionMode: 'Default' // Default | HighPerformance
    sharedKey: 'Passw0rd!'
    dpdTimeoutSeconds: 0
    vpnGatewayCustomBgpAddresses: []
    ipsecPolicies: [
      {
        saDataSizeKilobytes: 1024000 // 1024000 | 102400 | 51200 | 30720 | 20480 | 10240 | 5120 | 2048 | 1024 | 512 | 256 | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1
        saLifeTimeSeconds: 27000 // 27000 | 14400 | 28800 | 3600 | 10800 | 7200 | 4800 | 3600 | 2880 | 2400 | 1440 | 1200 | 720 | 480 | 360 | 240 | 180 | 120 | 60 | 30
        ipsecEncryption: 'AES256' // AES256 | AES128 | DES3 | DES | DES2
        ipsecIntegrity: 'SHA256' // SHA256 | SHA1 | MD5
        ikeEncryption: 'AES256' // AES256 | AES192 | AES128 | DES3 | DES | DES2
        ikeIntegrity: 'SHA256' // SHA256 | SHA1 | MD5
        dhGroup: 'DHGroup24' // DHGroup24 | DHGroup2 | DHGroup14 | DHGroup1 | ECP384 | ECP256
        pfsGroup: 'PFS24' // PFS24 | PFS2 | PFS14 | PFS1
      }
    ]
  }
]

// Azure Firewall Properties

param skuName = 'Standard' // Standard | Premium
param tier = 'Standard' // Standard | Premium
param mode = 'Off' // Alert | Deny | Off
param numberOfPublicIPs = 1

// Virtual Network Properties

param virtualNetwork = [
  {
    name: 'conwus2vnet' // Primary Virtual Network Name
    addressPrefixes: [
      '10.1.0.0/18' // Primary Address Prefix
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
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-DnsInboundSn-nsg')
    }
    {
      name: toLower('${virtualNetworkName}-DnsOutboundSn')
      addressPrefix: '10.1.3.0/24'
      delegation: 'Microsoft.Network/dnsResolvers'
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-DnsOutboundSn-nsg')
    }
  ]
  }
  {
    name: 'coneus2vnet' // Secondary Virtual Network Name
    addressPrefixes: [
    '10.2.0.0/18' // Secondary Address Prefix
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
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-PrivateEndpointSn-nsg')
    }
    {
      name: toLower('${virtualNetworkName}-DnsInboundSn')
      addressPrefix: '10.1.2.0/24'
      delegation: 'Microsoft.Network/dnsResolvers'
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-DnsInboundSn-nsg')
    }
    {
      name: toLower('${virtualNetworkName}-DnsOutboundSn')
      addressPrefix: '10.1.3.0/24'
      delegation: 'Microsoft.Network/dnsResolvers'
      networkSecurityGroupResourceId: toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkName}-DnsOutboundSn-nsg')
    }
  ]
  }
]

// Network Security Group Properties

param nsgSuffix = '${nameSeparator}nsg'
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



param vpnGatewayScaleUnit = 1
