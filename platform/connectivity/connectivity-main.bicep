targetScope = 'subscription'

// Deployment Boolean Parameters

param enableUserAssignedManagedIdentity bool
param enableVirtualHub bool
param enableVirtualWan bool
param enableAzureFirewall bool
param enableVpnSite bool
param enableNetworkSecurityGroups bool
param enablePrivateDnsZones bool
param enableDnsResolver bool
param enableOutboundDns bool
param enableVirtualNetwork bool
param enableBastion bool
param enableOperationalInsights bool
param enableVpnGateway bool
param enableKeyVault bool
param enableStorageAccount bool

// Deployment Options
@description('Deployment Options')
param subscriptionId string
param locations array
param tags object
param nameSeparator string

// Resource Names

param virtualWanName string
param virtualHubName array
param vpnGatewayName array
param vpnSiteName array
param firewallName array
param firewallPolicyName array

// Resource Arrays

param uamiName array
param bastionName array
param dnsResolverName array
param operationalInsightsName array
param keyVaultName array
param storageAccountName array
param dnsForwardingRulesetName array
param dnsForwardingOutboundRules array
param appInsightsName array

// DNS Servers

param dnsServers array

// Resource Maps

param azureFirewall azureFirewallType
type azureFirewallType = {
  skuName: 'Standard' | 'Premium'
  numberOfPublicIPs: int
}

param azureFirewallPolicy azureFirewallPolicyType
type azureFirewallPolicyType = {
  skuName: 'Standard' | 'Premium'
  tier: 'Standard' | 'Premium'
  mode: 'Alert' | 'Deny' | 'Off'
  numberOfPublicIPs: int
  allowSqlRedirect: bool
  autoLearnPrivateRanges: 'Disabled' | 'Enabled'
}
param keyVault keyVaultType
type keyVaultType = {
  sku: 'standard' | 'premium'
  accessPolicies: array
  publicNetworkAccess: 'Enabled' | 'Disabled'
  bypass: 'AzureServices' | 'None'
  defaultAction: 'Allow' | 'Deny'
  ipRules: array
  virtualNetworkRules: array
  enablePurgeProtection: bool
  softDeleteRetentionInDays: int
  enableRbacAuthorization: bool
}
param bastion bastionType
type bastionType = {
  skuName: 'Standard' | 'Basic'
  disableCopyPaste: bool
  disableVpnEncryption: bool
  dnsFirewallProxy: array
  dnsPrivateResolver: array
  enableFileCopy: bool
  enableIpConnect: bool
  enableShareableLink: bool
  scaleUnits: int
}
param virtualWan virtualWanType
type virtualWanType = {
  virtualWanSku: 'Basic' | 'Standard'
  allowBranchToBranchTraffic: bool
  disableVpnEncryption: bool
}
param virtualWanHub virtualWanHubType
type virtualWanHubType = {
  addressPrefix: string
  internetToFirewall: bool
  privateToFirewall: bool
  preferredRoutingGateway: 'VpnGateway' | 'ExpressRoute' | 'None' | ''
  enableTelemetry: bool
  virtualRouterAsn: int
  defaultRouteTableName: string
  sku: 'Basic' | 'Standard'
}
param vpnGateway vpnGatewayType
type vpnGatewayType = {
  asn: int
  vpnGatewayScaleUnit: int
  peerWeight: int
  isRoutingPreferenceInternet: bool
  enableBgpRouteTranslationForNat: bool
  enableTelemetry: bool
}
param vpnSite vpnSiteType
type vpnSiteType = {
  addressPrefixes: array // Remote VPN Site subnets (if not using BGP)
  o365Policy: {
    breakOutCategories: {
      allow: bool
      default: bool
      optimize: bool
    }
  }
}
param vpnConnection vpnConnectionType
type vpnConnectionType = {
  connectionBandwidth: int
  enableBgp: bool
  enableInternetSecurity: bool
  enableRateLimiting: bool
  ipsecPolicies: array
  remoteVpnSiteResourceId: string
  routingConfiguration: {
    associatedRouteTable: {
      id: string
    }
    propagatedRouteTables: {
      ids: array
      labels: array
    }
  }
  routingWeight: int
  sharedKey: string
  trafficSelectorPolicies: array
  useLocalAzureIpAddress: bool
  usePolicyBasedTrafficSelectors: bool
  vpnConnectionProtocolType: 'IKEv2' | 'IKEv1'
  vpnLinkConnections: array
}

param storageAccount storageAccountType
type storageAccountType = {
  accountTier: 'Standard' | 'Premium'
  requireInfrastructureEncryption: bool
  sasExpirationPeriod: string
  skuName:
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_LRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'Standard_ZRS'
  accountReplicationType: 'LRS' | 'GRS' | 'RAGRS' | 'ZRS' | 'GZRS' | 'RA_GRS'
  accountKind: 'Storage' | 'StorageV2' | 'BlobStorage' | 'BlockBlobStorage'
  accountAccessTier: 'Hot' | 'Cool' | 'Archive'
  allowBlobPublicAccess: bool
  blobServices: {
    automaticSnapshotPolicyEnabled: bool
    containerDeleteRetentionPolicyDays: int
    containerDeleteRetentionPolicyEnabled: bool
    containers: array
    deleteRetentionPolicyDays: int
    deleteRetentionPolicyEnabled: bool
  }
  enableHierarchicalNamespace: bool
  enableNfsV3: bool
  enableSftp: bool
  fileServices: {
    shareDeleteRetentionPolicyDays: int
    shares: array
  }
  largeFileSharesState: 'Enabled' | 'Disabled'
  localUsers: array
  managementPolicyRules: array
  networkAcls: {
    bypass: 'AzureServices' | 'None'
    defaultAction: 'Allow' | 'Deny'
    ipRules: array
  }
}

// Resource Suffixes

param nsgSuffix string
param peSuffix string
param nicSuffix string

// Resource Group Parameters

param resourceGroupName_Network array
param resourceGroupName_Bastion array
param resourceGroupName_PrivateDns string

param roleAssignmentsNetwork array
param roleAssignmentsBastion array
param roleAssignmentsPrivateDns array
param lock object

// Virtual Network Parameters

param virtualNetwork array
param subnets0 array
param subnets1 array

// Network Security Group Parameters

param securityRulesDefault array
param securityRulesBastion array

// Firewall Policy Parameters

param ruleCollectionGroups array

// Private DNS Parameters

param privatelinkDnsZoneNames array

// Network Resource Group Deployment
module modResourceGroupNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupNetworkDeployment${i}'
    params: {
      name: resourceGroupName_Network[i]
      tags: tags
      location: locations[i]
      // lock: lock
      roleAssignments: roleAssignmentsNetwork
    }
  }
]

// Bastion Resource Group Deployment

@description('Deploys a resource group for the Bastion host.')
module modResourceGroupBastion 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupBastionDeployment${i}'
    params: {
      name: resourceGroupName_Bastion[0]
      tags: tags
      location: locations[0]
      // lock: lock
      roleAssignments: roleAssignmentsBastion
    }
  }
]

// Private DNS Resource Group Deployment - Primary Region Only

module modResourceGroupDnsZones 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupDnsZonesDeployment'
  params: {
    name: resourceGroupName_PrivateDns
    tags: tags
    location: locations[0]
    // lock: lock
    roleAssignments: roleAssignmentsPrivateDns
  }
}

// User Assigned Managed Identity

module modUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = [
  for i in range(0, length(locations)): if (enableUserAssignedManagedIdentity) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'userAssignedIdentityDeployment${i}'
    params: {
      name: uamiName[i]
      tags: tags
      location: locations[i]
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Operational Insights Workspace

module modWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = [
  for i in range(0, length(locations)): if (enableOperationalInsights) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'workspaceDeployment${i}'
    params: {
      name: operationalInsightsName[i]
      location: locations[i]
      tags: tags
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Application Insights

module modComponent 'br/public:avm/res/insights/component:0.4.1' = [
  for i in range(0, length(locations)): if (enableOperationalInsights) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'componentDeployment${i}'
    params: {
      name: appInsightsName[i]
      workspaceResourceId: modWorkspace[i].outputs.resourceId
      location: locations[i]
    }
    dependsOn: [
      modWorkspace
    ]
  }
]

// Monitoring

module modMonitoring 'br/public:avm/ptn/azd/monitoring:0.1.0' = [
  for i in range(0, length(locations)): if (enableOperationalInsights) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'monitoringDeployment${i}'
    params: {
      applicationInsightsName: modComponent[i].outputs.name
      logAnalyticsName: operationalInsightsName[i]
      location: locations[i]
    }
    dependsOn: [
      modWorkspace
      modComponent
    ]
  }
]

// Network Security Groups - Primary Region

module modNetworkSecurityGroupPrimary 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnet in subnets0: if (enableNetworkSecurityGroups) {
    scope: resourceGroup(resourceGroupName_Network[0])
    name: 'nsgDeployment${subnet.name}'
    params: {
      name: toLower('${subnet.name}${nsgSuffix}')
      tags: tags
      location: locations[0]
      securityRules: (subnet.name == 'AzureBastionSubnet') ? securityRulesBastion : securityRulesDefault
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Network Security Groups - Secondary Region

module modNetworkSecurityGroupSecondary 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnet in subnets1: if ((enableNetworkSecurityGroups) && length(locations) == 2) {
    scope: resourceGroup(resourceGroupName_Network[1])
    name: 'nsgDeployment${subnet.name}'
    params: {
      name: toLower('${subnet.name}${nsgSuffix}')
      tags: tags
      location: locations[1]
      securityRules: (subnet.name == 'AzureBastionSubnet') ? securityRulesBastion : securityRulesDefault
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Virtual Network

module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'virtualNetworkDeployment${i}'
    params: {
      name: virtualNetwork[i].name
      location: locations[i]
      tags: tags
      addressPrefixes: virtualNetwork[i].addressPrefixes
      dnsServers: dnsServers
      subnets: (i == 0) ? subnets0 : subnets1
      diagnosticSettings: [
        {
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
    }
    dependsOn: [
      modNetworkSecurityGroupPrimary
    ]
  }
]

// Private DNS Zones

module modPrivateDnsZones 'br/public:avm/res/network/private-dns-zone:0.6.0' = [
  for privatelinkDnsZoneName in privatelinkDnsZoneNames: if (enablePrivateDnsZones) {
    scope: resourceGroup(resourceGroupName_PrivateDns)
    name: '${privatelinkDnsZoneName}Deployment'
    params: {
      name: privatelinkDnsZoneName
      tags: tags
      virtualNetworkLinks: [
        for i in range(0, length(locations)): {
          registrationEnabled: false
          virtualNetworkResourceId: modVirtualNetwork[i].outputs.resourceId
        }
      ]
    }
    dependsOn: [
      modVirtualNetwork
    ]
  }
]

// DNS Private Resolver
@description('Deploys a DNS Resolver for managing DNS queries within the network.')
module modDnsResolver 'br/public:avm/res/network/dns-resolver:0.5.0' = if (enableDnsResolver) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'DnsResolverDeployment'
  params: {
    name: dnsResolverName[0]
    location: locations[0]
    tags: tags
    inboundEndpoints: [
      {
        name: 'InboundEndpoint-01'
        subnetResourceId: modVirtualNetwork[0].outputs.subnetResourceIds[2]
      }
    ]
    outboundEndpoints: (enableOutboundDns)
      ? [
          {
            name: 'OutboundEndpoint-01'
            subnetResourceId: modVirtualNetwork[0].outputs.subnetResourceIds[3]
          }
        ]
      : []
    virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
  }
  dependsOn: [
    modPrivateDnsZones
    modVirtualNetwork
  ]
}

// DNS Resolver Forwarder

@description('Deploys a DNS Forwarding Ruleset for outbound DNS resolution.')
module dnsForwardingRuleset 'br/public:avm/res/network/dns-forwarding-ruleset:0.5.0' = if (enableOutboundDns) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'dnsForwardingRulesetDeployment'
  params: {
    dnsForwardingRulesetOutboundEndpointResourceIds: [
      '${modDnsResolver.outputs.resourceId}/outboundEndpoints/OutboundEndpoint-01'
    ]
    name: dnsForwardingRulesetName[0]
    forwardingRules: dnsForwardingOutboundRules
    location: locations[0]
    lock: {}
    roleAssignments: []
    tags: tags
    virtualNetworkLinks: [
      {
        name: 'ruleset-to-vnet'
        virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
      }
    ]
  }
  dependsOn: []
}

// Virtual WAN - Primary Region Only
@description('Deploys a Virtual WAN for network connectivity.')
module modVirtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = if (enableVirtualWan) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'virtualWanDeployment'
  params: {
    name: virtualWanName
    allowBranchToBranchTraffic: virtualWan.allowBranchToBranchTraffic
    disableVpnEncryption: virtualWan.disableVpnEncryption
    type: virtualWan.virtualWanSku
    location: locations[0]
    tags: tags
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// Virtual WAN Hub - Primary Region Only (change 0 to i for multi-region)
@description('Deploys a Virtual Hub for network connectivity.')
module modVirtualHub 'br/public:avm/res/network/virtual-hub:0.2.2' = [
  for i in range(0, length(locations)): if (enableVirtualHub) {
    scope: resourceGroup(resourceGroupName_Network[0])
    name: 'virtualHubDeployment${i}'
    params: {
      name: virtualHubName[0]
      location: locations[0]
      tags: tags
      addressPrefix: virtualWanHub.addressPrefix
      virtualWanId: modVirtualWan.outputs.resourceId
      sku: virtualWanHub.sku
      internetToFirewall: virtualWanHub.internetToFirewall
      privateToFirewall: virtualWanHub.privateToFirewall
      preferredRoutingGateway: virtualWanHub.preferredRoutingGateway
      enableTelemetry: virtualWanHub.enableTelemetry
      virtualRouterAsn: virtualWanHub.virtualRouterAsn
      hubRouteTables: []
      hubVirtualNetworkConnections: [
        for i in range(0, length(locations)): {
          name: '${virtualNetwork[i].name}-to-${virtualHubName[0]}'
          remoteVirtualNetworkId: modVirtualNetwork[i].outputs.resourceId
          routingConfiguration: {
            associatedRouteTable: {
              id: '${modResourceGroupNetwork[0].outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName[0]}/hubRouteTables/${virtualWanHub.defaultRouteTableName}'
            }
            propagatedRouteTables: {
              ids: [
                {
                  id: '${modResourceGroupNetwork[0].outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName[0]}/hubRouteTables/${virtualWanHub.defaultRouteTableName}'
                }
              ]
              labels: []
            }
          }
        }
      ]
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// VPN Site for VWAN-to-VWAN connections

module modVpnSite 'br/public:avm/res/network/vpn-site:0.3.0' = if (enableVpnSite) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'vpnSiteDeployment'
  params: {
    name: vpnSiteName[0]
    virtualWanId: modVirtualWan.outputs.resourceId
    location: locations[0]
    tags: tags
    addressPrefixes: vpnSite.addressPrefixes
    o365Policy: {
      breakOutCategories: {
        allow: vpnSite.o365Policy.breakOutCategories.allow
        default: vpnSite.o365Policy.breakOutCategories.default
        optimize: vpnSite.o365Policy.breakOutCategories.optimize
      }
    }
    vpnSiteLinks: [
      {
        name: 'DataCenter1'
        properties: {
          bgpProperties: {
            asn: 65010
            bgpPeeringAddress: '1.1.1.1'
          }
          ipAddress: '1.2.3.4'
          linkProperties: {
            linkProviderName: 'Verizon'
            linkSpeedInMbps: 100
          }
        }
      }
      {
        name: 'DataCenter2'
        properties: {
          bgpProperties: {
            asn: 65020
            bgpPeeringAddress: '1.1.1.2'
          }
          ipAddress: '1.2.3.5'
          linkProperties: {
            linkProviderName: 'Verizon'
            linkSpeedInMbps: 100
          }
        }
      }
    ]
  }
  dependsOn: [
    modVirtualHub
  ]
}

// VPN Gateway for Site-to-Site, Point-to-Site or VWAN-to-VWAN

module modVpnGateway 'br/public:avm/res/network/vpn-gateway:0.1.3' = if (enableVpnGateway) {
  scope: (resourceGroup(resourceGroupName_Network[0]))
  name: 'vpnGatewayDeployment'
  params: {
    name: vpnGatewayName[0]
    virtualHubResourceId: modVirtualHub[0].outputs.resourceId
    location: locations[0]
    tags: tags
    bgpSettings: {
      asn: vpnGateway.asn
      peerweight: vpnGateway.peerweight
    }
    isRoutingPreferenceInternet: vpnGateway.isRoutingPreferenceInternet
    enableBgpRouteTranslationForNat: vpnGateway.enableBgpRouteTranslationForNat
    enableTelemetry: vpnGateway.enableTelemetry
    vpnGatewayScaleUnit: vpnGateway.vpnGatewayScaleUnit
    vpnConnections: []
  }
  dependsOn: [
    modVpnSite
    modVirtualNetwork
  ]
}

module vpnConnection 'vpn-connection/main.bicep' = {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'vpnConnectionDeployment'
  params: {
    connectionBandwidth: vpnConnection.connectionBandwidth
    enableBgp: vpnConnection.enableBgp
    enableInternetSecurity: vpnConnection.enableInternetSecurity
    enableRateLimiting: vpnConnection.enableRateLimiting
    ipsecPolicies: vpnConnection.ipsecPolicies
    remoteVpnSiteResourceId: modVpnSite.outputs.resourceId
    routingConfiguration: vpnConnection.routingConfiguration
    routingWeight: vpnConnection.routingWeight
    sharedKey: vpnConnection.sharedKey
    trafficSelectorPolicies: vpnConnection.trafficSelectorPolicies
    useLocalAzureIpAddress: vpnConnection.useLocalAzureIpAddress
    usePolicyBasedTrafficSelectors: vpnConnection.usePolicyBasedTrafficSelectors
    vpnConnectionProtocolType: vpnConnection.vpnConnectionProtocolType
    vpnLinkConnections: vpnConnection.vpnLinkConnections
  }
}


// Firewall Policy
module modFirewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.3' = if (enableAzureFirewall) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'firewallPolicyDeployment'
  params: {
    name: firewallPolicyName[0]
    tags: tags
    allowSqlRedirect: azureFirewallPolicy.allowSqlRedirect
    autoLearnPrivateRanges: azureFirewallPolicy.autoLearnPrivateRanges
    location: locations[0]
    mode: azureFirewallPolicy.mode
    ruleCollectionGroups: ruleCollectionGroups
    tier: azureFirewallPolicy.tier
  }
  dependsOn: [
    modVirtualHub
  ]
}

// Azure Firewall

module modAzureFirewall 'br/public:avm/res/network/azure-firewall:0.5.0' = if (enableAzureFirewall) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'azureFirewallDeployment'
  params: {
    name: firewallName[0]
    location: locations[0]
    tags: tags
    firewallPolicyId: modFirewallPolicy.outputs.resourceId
    hubIPAddresses: {
      publicIPs: {
        count: azureFirewall.numberOfPublicIPs
      }
    }
    virtualHubId: modVirtualHub[0].outputs.resourceId
  }
  dependsOn: []
}

// Azure Bastion Host

module modBastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = [
  for i in range(0, length(locations)): if (enableBastion) {
    scope: resourceGroup(resourceGroupName_Bastion[0])
    name: 'AzureBastionDeployment${i}'
    params: {
      name: bastionName[0]
      location: locations[0]
      virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
      tags: tags
      disableCopyPaste: bastion.disableCopyPaste
      enableIpConnect: bastion.enableIpConnect
      enableFileCopy: bastion.enableFileCopy
      scaleUnits: bastion.scaleUnits
      enableShareableLink: bastion.enableShareableLink
      skuName: bastion.skuName
    }
    dependsOn: [
      modVirtualNetwork
    ]
  }
]

// Key Vault

module modKeyVault 'br/public:avm/res/key-vault/vault:0.9.0' = [
  for i in range(0, length(locations)): if (enableKeyVault) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'vaultDeployment${i}'
    params: {
      name: keyVaultName[i]
      location: locations[i]
      sku: keyVault.sku
      accessPolicies: keyVault.accessPolicies
      diagnosticSettings: [
        {
          logCategoriesAndGroups: [
            {
              category: 'AzurePolicyEvaluationDetails'
            }
            {
              category: 'AuditEvent'
            }
          ]
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
      enablePurgeProtection: keyVault.enablePurgeProtection
      enableRbacAuthorization: keyVault.enableRbacAuthorization
      roleAssignments: []
      secrets: []
      softDeleteRetentionInDays: keyVault.softDeleteRetentionInDays
      tags: tags
      keys: []
      lock: {}
      publicNetworkAccess: keyVault.publicNetworkAccess
      networkAcls: {
        bypass: keyVault.bypass
        defaultAction: keyVault.defaultAction
        ipRules: keyVault.ipRules
        virtualNetworkRules: keyVault.virtualNetworkRules
      }
      privateEndpoints: [
        {
          tags: tags
          customDnsConfigs: []
          name: '${keyVaultName[i]}${peSuffix}'
          customNetworkInterfaceName: '${keyVaultName[i]}${nicSuffix}'
          ipConfigurations: []
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
              }
            ]
          }
          roleAssignments: []
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
      ]
    }
    dependsOn: [
      modVirtualNetwork
    ]
  }
]

// Storage Account

module modStorageAccount 'br/public:avm/res/storage/storage-account:0.14.3' = [
  for i in range(0, length(locations)): if (enableStorageAccount) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'storageAccountDeployment${i}'
    params: {
      name: storageAccountName[i]
      allowBlobPublicAccess: storageAccount.allowBlobPublicAccess
      enableHierarchicalNamespace: storageAccount.enableHierarchicalNamespace
      enableNfsV3: storageAccount.enableNfsV3
      enableSftp: storageAccount.enableSftp
      largeFileSharesState: storageAccount.largeFileSharesState
      localUsers: storageAccount.localUsers
      location: locations[i]
      lock: {}
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          modUserAssignedIdentity[i].outputs.resourceId
        ]
      }
      managementPolicyRules: storageAccount.managementPolicyRules
      networkAcls: {
        bypass: storageAccount.networkAcls.bypass
        defaultAction: storageAccount.networkAcls.defaultAction
        ipRules: storageAccount.networkAcls.ipRules
      }
      diagnosticSettings: [
        {
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
      blobServices: {
        automaticSnapshotPolicyEnabled: storageAccount.blobServices.automaticSnapshotPolicyEnabled
        containerDeleteRetentionPolicyDays: storageAccount.blobServices.containerDeleteRetentionPolicyDays
        containerDeleteRetentionPolicyEnabled: storageAccount.blobServices.containerDeleteRetentionPolicyEnabled
        containers: storageAccount.blobServices.containers
        deleteRetentionPolicyDays: storageAccount.blobServices.deleteRetentionPolicyDays
        deleteRetentionPolicyEnabled: storageAccount.blobServices.deleteRetentionPolicyEnabled
        diagnosticSettings: [
          {
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            name: 'customSetting'
            workspaceResourceId: modWorkspace[i].outputs.resourceId
          }
        ]
      }
      fileServices: {
        shareDeleteRetentionPolicyDays: storageAccount.fileServices.shareDeleteRetentionPolicyDays
        diagnosticSettings: [
          {
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            name: 'customSetting'
            workspaceResourceId: modWorkspace[i].outputs.resourceId
          }
        ]
        shares: storageAccount.fileServices.shares
      }
      privateEndpoints: [
        {
          name: '${storageAccountName[i]}${peSuffix}${nameSeparator}blob'
          customNetworkInterfaceName: '${storageAccountName[i]}${nicSuffix}${nameSeparator}blob'
          ipConfigurations: []
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones.outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
              }
            ]
          }
          service: 'blob'
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
        {
          name: '${storageAccountName[i]}${peSuffix}${nameSeparator}file'
          customNetworkInterfaceName: '${storageAccountName[i]}${nicSuffix}${nameSeparator}file'
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones.outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
              }
            ]
          }
          service: 'file'
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
      ]
      requireInfrastructureEncryption: storageAccount.requireInfrastructureEncryption
      roleAssignments: []
      sasExpirationPeriod: storageAccount.sasExpirationPeriod
      skuName: storageAccount.skuName
      tags: tags
    }
    dependsOn: [
      modVirtualNetwork
      modPrivateDnsZones
    ]
  }
]
