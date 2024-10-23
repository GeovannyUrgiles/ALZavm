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

// Virtual Hub Connectivity

param spokes array

// Deployment Options

param subscriptionId string
param locations array
param locationsShort array
param tags object
param nameSeparator string

// Resource Names

param virtualWanName string
param virtualHubName string
param uamiName array
param bastionName array
param dnsResolverName array
param vpnSiteName string
param operationalInsightsName array
param firewallName string
param firewallPolicyName string
param vpnGatewayName string
param keyVaultName array

// DNS Servers

param dnsServers array

// Resource Maps

param azureFirewall object
param azureFirewallPolicy object
param keyVault object
param bastion object
param virtualWan object
param virtualWanHub object
param vpnGateway object

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

// VPN Gateway Site-to-Site

param vpnSiteLinks array
param vpnConnections array

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

// Bastion  Resource Group Deployment

module modResourceGroupBastion 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupBastionDeployment${i}'
    params: {
      name: resourceGroupName_Bastion[i]
      tags: tags
      location: locations[i]
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
    name: 'workspaceDeployment'
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

module modDnsResolver 'br/public:avm/res/network/dns-resolver:0.5.0' = if (enableDnsResolver) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'DnsResolverDeployment'
  params: {
    name: dnsResolverName[0]
    location: locations[0]
    tags: tags
    inboundEndpoints: [
      {
        name: 'InboundEndpoint'
        subnetResourceId: modVirtualNetwork[0].outputs.subnetResourceIds[2]
      }
    ]
    outboundEndpoints: (enableOutboundDns)
      ? [
          {
            name: 'OutboundEndpoint'
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

// Virtual WAN - Primary Region Only

module modVirtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = if (enableVirtualWan) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'virtualWanDeployment'
  params: {
    name: virtualWanName
    disableVpnEncryption: virtualWan.disableVpnEncryption
    type: virtualWan.virtualWanSku
    location: locations[0]
    tags: tags
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// Virtual WAN Hub

module modVirtualHub 'br/public:avm/res/network/virtual-hub:0.2.2' = [
  for i in range(0, length(locations)): if (enableVirtualHub) {
    scope: resourceGroup(resourceGroupName_Network[0])
    name: 'virtualHubDeployment${i}'
    params: {
      name: virtualHubName
      location: locations[0]
      tags: tags
      addressPrefix: virtualWanHub.addressPrefix
      virtualWanId: modVirtualWan.outputs.resourceId
      sku: virtualWanHub.sku
      allowBranchToBranchTraffic: virtualWanHub.allowBranchToBranchTraffic
      internetToFirewall: virtualWanHub.internetToFirewall
      privateToFirewall: virtualWanHub.privateToFirewall
      preferredRoutingGateway: virtualWanHub.preferredRoutingGateway
      enableTelemetry: virtualWanHub.enableTelemetry
      virtualRouterAsn: virtualWanHub.virtualRouterAsn
      hubRouteTables: [
        {
          name: virtualWanHub.defaultRoutesName
        }
      ]
      hubVirtualNetworkConnections: [
        for i in range(0, length(locations)): {
          name: '${virtualNetwork[i]}-to-${virtualHubName}'
          remoteVirtualNetworkId: modVirtualNetwork[i].outputs.resourceId // /subscription/${subscription}/resourceGroups/${spoke.rg}/providers/Microsoft.Network/virtualNetworks/${spoke.vnet}
          routingConfiguration: {
            associatedRouteTable: {
              id: '${modResourceGroupNetwork[i].outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${virtualWanHub.defaultRoutesName}'
            }
            propagatedRouteTables: {
              ids: [
                {
                  id: '${modResourceGroupNetwork[i].outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${virtualWanHub.defaultRoutesName}'
                }
              ]
              labels: [
                virtualWanHub.defaultRoutesName
              ]
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
    name: vpnSiteName
    virtualWanId: modVirtualWan.outputs.resourceId
    location: locations[0]
    tags: tags
    addressPrefixes: []
    o365Policy: {
      breakOutCategories: {
        allow: true
        default: true
        optimize: true
      }
    }
    vpnSiteLinks: [
      //vpnSiteLinks[0]
      (enableVpnSite)
        ? {
            name: 'azureSite1'
            id: '/subscriptions/${subscriptionId}/resourceGroups/${string(resourceGroupName_Network[0])}/providers/Microsoft.Network/vpnSites/${vpnSiteName}/vpnSiteLinks/azureSite1'
            properties: {
              // vpnLinkConnectionMode: 'Default' // Default | HighPerformance
              bgpProperties: {
                asn: 65010 // BGP Autonomous System Number
                bgpPeeringAddress: '1.1.1.1'
              }
              ipAddress: '2.2.2.2' // Remote VPN Gateway IP Address or FQDN
              linkProperties: {
                linkProviderName: 'Verizon' // Verizon | ATT | BT | Orange | Vodafone
                linkSpeedInMbps: 100 // 5 | 10 | 20 | 50 | 100 | 200 | 500 | 1000 | 2000 | 5000 | 10000
              }
            }
          }
        : {}
    ]
    //
    // deviceProperties: {
    //   // deviceVendor:  'Cisco' // Cisco | Juniper | Microsoft | PaloAltoNetworks
    //   // linkSpeedInMbps: 100
    // }
  }
  dependsOn: [
    modVirtualHub
  ]
}

// VPN Gateway for Site-to-Site, Point-to-Site or VWAN-to-VWAN

module modVpnGateway 'br/public:avm/res/network/vpn-gateway:0.1.3' = [
  for i in range(0, length(locations)): if (enableVpnGateway) {
    scope: (resourceGroup(resourceGroupName_Network[0]))
    name: 'vpnGatewayDeployment${i}'
    params: {
      name: vpnGatewayName
      virtualHubResourceId: modVirtualHub[0].outputs.resourceId
      location: locations[0]
      tags: tags
      bgpSettings: {
        asn: vpnGateway.asn
        peerweight: vpnGateway.peerweight
      }
      vpnGatewayScaleUnit: vpnGateway.vpnGatewayScaleUnit
      vpnConnections: [
        {
          name: vpnConnections[i].name
          connectionBandwidth: vpnConnections[i].connectionBandwidth
          enableBgp: vpnConnections[i].enableBgp
          enableInternetSecurity: vpnConnections[i].enableInternetSecurity
          enableRateLimiting: vpnConnections[i].enableRateLimiting
          routingWeight: vpnConnections[i].routingWeight
          useLocalAzureIpAddress: vpnConnections[i].useLocalAzureIpAddress
          usePolicyBasedTrafficSelectors: vpnConnections[i].usePolicyBasedTrafficSelectors
          vpnConnectionProtocolType: vpnConnections[i].vpnConnectionProtocolType

          // remoteVpnSiteResourceId: modVpnSite.outputs.resourceId

          vpnLinkConnectionMode: vpnConnections[i].vpnLinkConnectionMode
          sharedKey: vpnConnections[i].sharedKey
          dpdTimeoutSeconds: vpnConnections[i].dpdTimeoutSeconds
          vpnGatewayCustomBgpAddresses: vpnConnections[i].vpnGatewayCustomBgpAddresses
          ipsecPolicies: vpnConnections[i].ipsecPolicies
        }
      ]
    }
    dependsOn: [
      modVirtualHub
    ]
  }
]

// Firewall Policy

// param userAssignedResourceIds array = [
//   userAssignedIdentity.outputs.resourceId
// ]
// ]

// var formattedUserAssignedIdentities = reduce(
//   map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
//   {},
//   (cur, next) => union(cur, next)
// ) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

// @description('Optional. The managed identity definition for this resource.')
// param managedIdentities managedIdentitiesType

// var identity = !empty(managedIdentities)
//   ? {
//       type: 'UserAssigned'
//       userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
//     }
//   : null

// // =============== //
// //   Definitions   //
// // =============== //

// type managedIdentitiesType = {
//   @description('Optional. The resource ID(s) to assign to the resource.')
//   userAssignedResourceIds: string[]
// }?

module modFirewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.3' = if (enableAzureFirewall) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'firewallPolicyDeployment'
  params: {
    name: firewallPolicyName
    tags: tags
    allowSqlRedirect: azureFirewallPolicy.allowSqlRedirect
    autoLearnPrivateRanges: azureFirewallPolicy.autoLearnPrivateRanges
    location: locations[0]

    // identity: identity

    managedIdentities: {
      userAssignedResourceIds: [
        modUserAssignedIdentity[0].outputs.resourceId
      ]
    }

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
    name: firewallName
    tags: tags
    firewallPolicyId: modFirewallPolicy.outputs.resourceId
    hubIPAddresses: {
      publicIPs: {
        count: azureFirewall.numberOfPublicIPs
      }
    }
    location: locations[0]
    virtualHubId: modVirtualHub[0].outputs.resourceId
  }
  dependsOn: [
    modFirewallPolicy
  ]
}

// Azure Bastion Host

module bastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = if (enableBastion) {
  scope: resourceGroup(resourceGroupName_Bastion[0])
  name: 'AzureBastionDeployment'
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

// Key Vault

module vault 'br/public:avm/res/key-vault/vault:0.9.0' = [
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
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones.outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
              }
            ]
          }
          roleAssignments: []
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
      ]
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]
