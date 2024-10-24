using 'main.bicep'

// IaC Version Number

var version = 'v1.0.0'

//-// Deployment Options

// Virtual Network
param enableVirtualNetwork = true
param enableNetworkSecurityGroups = true
param enableDnsResolver = false
param enableOutboundDns = false
param enablePrivateDnsZones = false

// Virtual WAN
param enableVirtualWan = true
param enableVirtualHub = true
param enableVpnSite = false
param enableVpnGateway = false
param enableAzureFirewall = false

// Supporting Resources
param enableUserAssignedManagedIdentity = true
param enableOperationalInsights = true
param enableKeyVault = true
param enableBastion = false
param enableStorageAccount = true

// param enableRecoveryServiceVault = true

param dnsServers = [
  '168.63.129.16'
]

// Subscription(s)

param subscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// Paired Regions

param locations = [
  'westus2' // Primary Region
 // 'eastus2' // Secondary Region
]

// Resource Group Names

var resourceGroupName_Networks = [
  'conwus2networkrg'
  'coneus2networkrg'
]
param resourceGroupName_Network = [
  'conwus2networkrg'
  'coneus2networkrg'
]
param resourceGroupName_Bastion = [
  'conwus2bastionrg'
  'coneus2bastionrg'
]
param resourceGroupName_PrivateDns = 'conwus2dnsrg'

// Virtual WAN Name

param virtualWanName = 'conwus2vwan'

// Virtual Network Names

var virtualNetworkNamePrimary = 'conwus2vnet'
var virtualNetworkNameSecondary = 'coneus2vnet'

// Virtual Network Property Array

param virtualNetwork = [
  {
    name: virtualNetworkNamePrimary // Primary Virtual Network Name
    addressPrefixes: [
      '10.1.0.0/18' // Primary Address Prefix
    ]
    subnets: [subnets0]
  }
  {
    name: virtualNetworkNameSecondary // Secondary Virtual Network Name
    addressPrefixes: [
      '10.2.0.0/18' // Secondary Address Prefix
    ]

    subnets: [subnets1]
  }
]

// Resource Name Arrays

param virtualHubName = [
  'conwus2hub'
  'coneus2hub'
]
param vpnGatewayName = [
  'conwus2vpngw'
  'coneus2vpngw'
]
param vpnSiteName = [
  'conwus2vpnsite'
  'coneus2vpnsite'
]
param firewallName = [
  'conwus2azfw'
  'coneus2azfw'
]
param firewallPolicyName = [
  'conwus2azfwpol'
  'coneus2azfwpol'
]
param bastionName = [
  'conwus2bh'
  'coneus2bh'
]
param dnsResolverName = [
  'conwus2dns'
  'coneus2dns'
]
param dnsForwardingRulesetName = [
  'conwus2dnsfr'
  'coneus2dnsfr'
]
param operationalInsightsName = [
  'conwus2oiw'
  'coneus2oiw'
]
param uamiName = [
  'conwus2mi'
  'coneus2mi'
]
param keyVaultName = [
  'conwus2kv01'
  'coneus2kv01'
]
param storageAccountName = [
  'conwus2diagsa01'
  'coneus2diagsa01'
]

// Key Vault Properties

param keyVault = {
  sku: 'standard' // standard | premium (lowercase) (premium SKU requires HSM)
  accessPolicies: []
  publicNetworkAccess: 'Disabled'
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
  enablePurgeProtection: false
  softDeleteRetentionInDays: 7
  enableRbacAuthorization: true
}

// Resource Suffixes

param nameSeparator = '-'
param nsgSuffix = '${nameSeparator}nsg'
param peSuffix = '${nameSeparator}pe'
param nicSuffix = '${nameSeparator}nic'

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

// VPN Gateway Properties

param vpnGateway = {
  asn: 65515 // BGP Autonomous System Number
  peerWeight: 0
}
// Azure Firewall Properties

param azureFirewall = {
  skuName: 'Standard' // Standard | Premium
  numberOfPublicIPs: 1
}

param azureFirewallPolicy = {
  skuName: 'Standard' // Standard | Premium
  tier: 'Standard' // Standard | Premium
  mode: 'Off' // Alert | Deny | Off
  numberOfPublicIPs: 1
  allowSqlRedirect: false // true | false
  autoLearnPrivateRanges: 'Disabled' // Disabled | Enabled
}

// Azure Bastion Properties
param bastion = {
  sku: 'Standard' // Standard | Basic
  disableCopyPaste: true
  disableVpnEncryption: true
  dnsFirewallProxy: []
  dnsPrivateResolver: []
  enableFileCopy: true
  enableIpConnect: true
  enableShareableLink: true
  scaleUnits: 2
}

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

// Virtual Network Subnets

param subnets0 = [
  // Primary Region Virtual Network Subnets
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.1.0.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Networks[0]}/providers/Microsoft.Network/networkSecurityGroups/AzureBastionSubnet${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn'
    addressPrefix: '10.1.1.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}dnsinboundsn'
    addressPrefix: '10.1.2.0/24'
    delegation: 'Microsoft.Network/dnsResolvers'
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}dnsinboundsn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}dnsoutboundsn'
    addressPrefix: '10.1.3.0/24'
    delegation: 'Microsoft.Network/dnsResolvers'
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}dnsoutboundsn${nsgSuffix}'
    serviceEndpoints: []
  }
]

param subnets1 = [
  // Secondary Region Virtual Network Subnets
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.2.0.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[1]}/providers/Microsoft.Network/networkSecurityGroups/AzureBastionSubnet${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNameSecondary}${nameSeparator}privateendpointsn'
    addressPrefix: '10.2.1.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[1]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNameSecondary}${nameSeparator}privateendpointsn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNameSecondary}${nameSeparator}dnsinboundsn'
    addressPrefix: '10.2.2.0/24'
    delegation: 'Microsoft.Network/dnsResolvers'
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[1]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNameSecondary}${nameSeparator}dnsinboundsn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNameSecondary}${nameSeparator}dnsoutboundsn'
    addressPrefix: '10.2.3.0/24'
    delegation: 'Microsoft.Network/dnsResolvers'
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[1]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNameSecondary}${nameSeparator}dnsoutboundsn${nsgSuffix}'
    serviceEndpoints: []
  }
]

// Network Security Group Properties

param securityRulesDefault = []
param securityRulesBastion = [
  // AzureBastionSubnet Security Rules per Microsoft
  {
    name: 'AllowHttpsInBound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'Internet'
      destinationPortRange: '443'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowGatewayManagerInBound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'GatewayManager'
      destinationPortRange: '443'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowLoadBalancerInBound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationPortRange: '443'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowBastionHostCommunicationInBound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationPortRanges: [
        '8080'
        '5701'
      ]
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 130
      direction: 'Inbound'
    }
  }
  {
    name: 'DenyAllInBound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      destinationPortRange: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 1000
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowSshRdpOutBound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      destinationPortRanges: [
        '22'
        '3389'
      ]
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 100
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowAzureCloudCommunicationOutBound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      destinationPortRange: '443'
      destinationAddressPrefix: 'AzureCloud'
      access: 'Allow'
      priority: 110
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowBastionHostCommunicationOutBound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationPortRanges: [
        '8080'
        '5701'
      ]
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Outbound'
    }
  }
  {
    name: 'AllowGetSessionInformationOutBound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Internet'
      destinationPortRanges: [
        '80'
        '443'
      ]
      access: 'Allow'
      priority: 130
      direction: 'Outbound'
    }
  }
  {
    name: 'DenyAllOutBound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 1000
      direction: 'Outbound'
    }
  }
]

// Virtual WAN Properties

param virtualWan = {
  addressPrefix: '10.0.0.0/23'
  virtualWanSku: 'Standard'
  defaultRoutesName: 'Default' // Default | None
  disableVpnEncryption: false
}

// VWAN Hub Properties

param virtualWanHub = {
  addressPrefix: '10.0.23/24'
  allowBranchToBranchTraffic: true
  internetToFirewall: false
  privateToFirewall: false
  preferredRoutingGateway: 'VpnGateway' // 'ExpressRoute' 'None'
  enableTelemetry: false
  virtualRouterAsn: 65515
  defaultRoutesName: 'Default'
  sku: 'Basic' // Standard | Basic
}

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
  'privatelink.azure-automation.net'
  // 'privatelink.azurecr.io'
  // 'privatelink.azurewebsites.net'
  // 'privatelink.azurestaticapps.net'
  // 'privatelink.analysis.windows.net'
  // 'privatelink.azurehdinsight.net'
  'privatelink.azure-api.net'
  // 'privatelink.azconfig.io'
  // 'privatelink.azure-devices.net'
  // 'privatelink.azuresynapse.net'
  'privatelink.agentsvc.azure-automation.net'
  // 'privatelink.batch.azure.com'
  'privatelink.blob.core.windows.net'
  // 'privatelink.cassandra.cosmos.azure.com'
  // 'privatelink.cognitiveservices.azure.com'
  'privatelink.database.windows.net'
  // 'privatelink.datafactory.azure.net'
  // 'privatelink.dev.azuresynapse.net'
  // 'privatelink.developer.azure-api.net'
  'privatelink.dfs.core.windows.net'
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
  'privatelink.openai.azure.com'
  'privatelink.oms.opinsights.azure.com'
  // 'privatelink.postgres.database.azure.com'
  'privatelink.purview.azure.com'
  // 'privatelink.purviewstudio.azure.com'
  // 'privatelink.prod.migration.windowsazure.com'
  // 'privatelink.pbidedicated.windows.net'
  'privatelink.queue.core.windows.net'
  // 'privatelink.redis.cache.windows.net'
  // 'privatelink.redisenterprise.cache.azure.net'
  // 'privatelink.search.windows.net'
  // 'privatelink.service.signalr.net'
  // 'privatelink.servicebus.windows.net'
  // 'privatelink.sql.azuresynapse.net'
  'privatelink.table.core.windows.net'
  // 'privatelink.table.cosmos.azure.com'
  // 'privatelink.tip1.powerquery.microsoft.com'
  'privatelink.vaultcore.azure.net'
  'privatelink.web.core.windows.net'
  // 'privatelink.gremlin.cosmos.azure.com'
]

// Storage Account (Diagnostics)

param storageAccount = {
  accountTier: 'Standard' // Standard | Premium
  requireInfrastructureEncryption: true
  sasExpirationPeriod: '180.00:00:00'
  skuName: 'Standard_LRS' // Standard_LRS | Standard_GRS | Standard_RAGRS | Standard_ZRS | Premium_LRS | Premium_ZRS | Premium_GRS | Premium_RAGRS
  accountReplicationType: 'LRS' // LRS | GRS | RAGRS | ZRS | GZRS | RA_GRS
  accountKind: 'StorageV2' // Storage | StorageV2 | BlobStorage | BlockBlobStorage
  accountAccessTier: 'Hot' // Hot | Cool | Archive
  allowBlobPublicAccess: false
  blobServices: {
    automaticSnapshotPolicyEnabled: true
    containerDeleteRetentionPolicyDays: 10
    containerDeleteRetentionPolicyEnabled: true
    containers: []
    deleteRetentionPolicyDays: 9
    deleteRetentionPolicyEnabled: true
  }
  enableHierarchicalNamespace: false
  enableNfsV3: false
  enableSftp: false
  fileServices: {
    shareDeleteRetentionPolicyDays: 10
    shares: []
  }
  largeFileSharesState: 'Enabled'
  localUsers: []
  managementPolicyRules: []
  networkAcls: {
    bypass: 'AzureServices' // AzureServices | None
    defaultAction: 'Deny'
    ipRules: []
  }
}
