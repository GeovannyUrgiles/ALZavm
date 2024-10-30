using 'connectivity-main.bicep'

// IaC Version Number

var version = 'v1.0.0'

//-// Deployment Options

// Virtual Network
param enableVirtualNetwork = true
param enableNetworkSecurityGroups = true
param enableDnsResolver = true
param enableOutboundDns = true // Enables Outbound DNS Forwarding Rules
param enablePrivateDnsZones = false

// Virtual WAN
param enableVirtualWan = true
param enableVirtualHub = false
param enableVpnSite = false
param enableVpnGateway = false
param enableAzureFirewall = false

// Supporting Resources
param enableUserAssignedManagedIdentity = true
param enableOperationalInsights = true
param enableKeyVault = true
param enableBastion = false
param enableStorageAccount = true

// DNS Servers will be applied to Virtual Networks

param dnsServers = [
  '168.63.129.16'
]

// Subscription(s)

param subscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// Paired Regions

param locations = [ // Client should deploy (at minimum) Virtual Networks into both regions to establish future DR capabilities
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
    name: 'DefaultDnatRuleCollectionGroup'
    priority: 100
    ruleCollections: [
      {
        action: {
          type: 'Allow'
        }
        name: 'DefaultDnatRuleCollection'
        priority: 110
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: []
      }
    ]
  }
  {
    name: 'DefaultNetworkRuleCollectionGroup'
    priority: 200
    ruleCollections: [
      {
        action: {
          type: 'Allow'
        }
        name: 'DefaultNetworkRuleCollection'
        priority: 110
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: []
      }
    ]
  }
  {
    name: 'DefaultApplicationRuleCollectionGroup'
    priority: 300
    ruleCollections: [
      {
        action: {
          type: 'Allow'
        }
        name: 'DefaultApplicationRuleCollection'
        priority: 110
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: []
      }
    ]
  }
]

// Virtual WAN Properties

param virtualWan = {
  virtualWanSku: 'Basic' // Basic | Standard // Use Basic for Site-to-Ste VPN, Standard for ExpressRoute
  defaultRoutesName: 'Default' // Default | None
  disableVpnEncryption: false
}

// VWAN Hub Properties

param virtualWanHub = {
  addressPrefix: '10.0.0.0/23' // Hub Address Prefix - minimum /24
  allowBranchToBranchTraffic: false // true | false // Allows traffic between VPN branches
  internetToFirewall: false
  privateToFirewall: false
  preferredRoutingGateway: '' // 'VpnGateway' | 'ExpressRoute' | 'None' // (requires Standard SKU)
  enableTelemetry: false
  virtualRouterAsn: 65515
  defaultRoutesName: 'Default'
  sku: 'Basic' // Basic | Standard // Use Basic for Site-to-Ste VPN, Standard for ExpressRoute
}

// VPN Gateway Properties

param vpnGateway = {
  asn: 65515 // BGP Autonomous System Number
  vpnGatewayScaleUnit: 1
  peerWeight: 0
  isRoutingPreferenceInternet: false
  enableBgpRouteTranslationForNat: false
  enableTelemetry: false
}

// VPN Site

param vpnSite = {
  addressPrefixes: [] // Remote VPN Site subnets (if not using BGP)
  o365Policy: {
    breakOutCategories: {
      allow: true
      default: true
      optimize: true
    }
  }
}

// Azure Firewall Properties

param azureFirewall = {
  skuName: 'Standard' // Standard | Premium
  numberOfPublicIPs: 1
}

// Azure Firewall Policy Properties

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

// DNS Resolver Outbound Ruleset

param dnsForwardingOutboundRules = [
  {
    domainName: 'clientdomain.com.' // Add trailing dot
    forwardingRuleState: 'Enabled'
    name: 'rule1'
    targetDnsServers: [
      {
        ipAddress: '192.168.0.1'
        port: 53
      }
    ]
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
  'privatelink.cus.backup.windowsazure.com'  //  Azure Backup - Recovery Services Vault - Be sure to change the regional prefix!!
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
