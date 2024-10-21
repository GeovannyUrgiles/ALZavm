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

param virtualNetworkName string
param virtualWanName string

param virtualWanSku string

param virtualHubName string
param uamiName string
param bastionName string
param dnsResolverName string
param vpnSiteName string
param operationalInsightsName string
param firewallName string
param firewallPolicyName string
param vpnGatewayName string
param keyVaultName string
param publicIpAddressName01 string

// Resource Suffixes

param nsgSuffix string
param peSuffix string
param nicSuffix string

// Key Vault Properties

param enablePurgeProtection bool
param enableRbacAuthorization bool

// Resource Group Parameters

param resourceGroupName_Network array
param resourceGroupName_Bastion array
param resourceGroupName_PrivateDns array

param roleAssignmentsNetwork array
param roleAssignmentsBastion array
param roleAssignmentsPrivateDns array
param lock object

// Virtual Network Parameters

param virtualNetwork array
// param subnets array

//param subnets array
param securityRules array
// param onPremDnsServer string
param dnsFirewallProxy array
param dnsPrivateResolver array

// VPN Gateway Site-to-Site

param vpnSiteLinks array

// Virtual WAN

param addressPrefix string
param allowVnetToVnetTraffic bool
param allowBranchToBranchTraffic bool

// Virtual WAN Hub Routing

param defaultRoutesName string
// param preferredRoutingGateway string
// param hubRoutingPreference string

param vpnConnections array

// Azure Firewall Parameters

param tier string
param numberOfPublicIPs int
param scaleUnits int
param ruleCollectionGroups array
param disableVpnEncryption bool
param mode string
// param bgpSettings int
param vpnGatewayScaleUnit int
// param enableTunneling bool
// param privateIPAllocationMethod string

// Private DNS Parameters

param privatelinkDnsZoneNames array

// Bastion Parameters

param skuName string
param disableCopyPaste bool
param enableFileCopy bool
param enableIpConnect bool
param enableShareableLink bool

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
// Private DNS Resource Group Deployment

module modResourceGroupDnsZones 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupDnsZonesDeployment${i}'
    params: {
      name: resourceGroupName_PrivateDns[i]
      tags: tags
      location: locations[i]
      // lock: lock
      roleAssignments: roleAssignmentsPrivateDns
    }
  }
]
// User Assigned Managed Identity

module modUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = [
  for i in range(0, length(locations)): if (enableUserAssignedManagedIdentity) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'userAssignedIdentityDeployment${i}'
    params: {
      name: uamiName
      tags: tags
      location: locations[i]
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]
// Operational Insights

module modWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = [
  for i in range(0, length(locations)): if (enableOperationalInsights) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'workspaceDeployment'
    params: {
      name: operationalInsightsName
      location: locations[i]
      tags: tags
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Virtual WAN

module modVirtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = if (enableVirtualWan) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'virtualWanDeployment'
  params: {
    name: virtualWanName
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    location: locations[0]
    tags: tags
    type: virtualWanSku
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// Virtual WAN Hub

module modVirtualHub 'br/public:avm/res/network/virtual-hub:0.2.2' = if (enableVirtualHub) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'virtualHubDeployment'
  params: {
    name: virtualHubName
    location: locations[0]
    tags: tags
    addressPrefix: addressPrefix
    virtualWanId: modVirtualWan.outputs.resourceId
    sku: 'Basic' // Standard | Basic
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    internetToFirewall: false
    privateToFirewall: false
    preferredRoutingGateway: 'ExpressRoute' // ExpressRoute
    enableTelemetry: false
    virtualRouterAsn: 65515
    hubRouteTables: [
      {
        name: defaultRoutesName
      }
    ]
    hubVirtualNetworkConnections: [
      // for RemoteSpoke in RemoteSpokes: {
      (enableVirtualNetwork)
        ? {
            name: '${virtualNetworkName}-to-${virtualHubName}'
            remoteVirtualNetworkId: modVirtualNetwork[0].outputs.resourceId // /subscription/${subscription}/resourceGroups/${spoke.rg}/providers/Microsoft.Network/virtualNetworks/${spoke.vnet}
            routingConfiguration: {
              associatedRouteTable: {
                id: '${modResourceGroupNetwork[0].outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${defaultRoutesName}'
              }
              propagatedRouteTables: {
                ids: [
                  {
                    id: '${modResourceGroupNetwork[0].outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${defaultRoutesName}'
                  }
                ]
                labels: [
                  defaultRoutesName
                ]
              }
            }
          }
        : {}
    ]
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// VPN Site for VWAN-to-VWAN connections

module modVpnSite 'br/public:avm/res/network/vpn-site:0.3.0' = if (enableVpnSite) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'vpnSiteDeployment'
  params: {
    name: vpnSiteName
    virtualWanId: modVirtualWan.outputs.resourceId
    location: locations[0]
    tags: tags
    addressPrefixes: [
      (enableVpnSite) ? addressPrefix : null
      // (enableVpnSite) ? virtualNetwork.addressPrefixes[0] : null
    ]
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
      virtualHubResourceId: modVirtualHub.outputs.resourceId
      location: locations[0]
      tags: tags
      bgpSettings: {
        asn: 65515
        peerweight: 0
      }
      vpnGatewayScaleUnit: vpnGatewayScaleUnit
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
    allowSqlRedirect: (tier == 'Premium') ? true : false
    autoLearnPrivateRanges: (tier == 'Premium') ? 'Enabled' : 'Disabled'
    location: locations[0]

    // identity: identity

    managedIdentities: {
      userAssignedResourceIds: [
        modUserAssignedIdentity[0].outputs.resourceId
      ]
    }

    mode: mode
    ruleCollectionGroups: ruleCollectionGroups
    tier: tier
  }
  dependsOn: [
    modVirtualHub
  ]
}

// Azure Firewall

module azureFirewall 'br/public:avm/res/network/azure-firewall:0.5.0' = if (enableAzureFirewall) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'azureFirewallDeployment'
  params: {
    name: firewallName
    tags: tags
    firewallPolicyId: modFirewallPolicy.outputs.resourceId
    hubIPAddresses: {
      publicIPs: {
        count: numberOfPublicIPs
      }
    }
    location: locations[0]
    virtualHubId: modVirtualHub.outputs.resourceId
  }
  dependsOn: [
    modFirewallPolicy
  ]
}

// Network Security Groups
module modNetworkSecurityGroupPrimary 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnet in virtualNetwork[0]: if (enableNetworkSecurityGroups) {
    scope: resourceGroup(resourceGroupName_Network[0])
    name: 'nsgDeployment${subnet.name}'
    params: {
      name: toLower('${subnet.name}${nsgSuffix}')
      tags: tags
      location: locations[0]
      securityRules: securityRules
    }
  }
]

// // Network Security Groups
// module modNetworkSecurityGroupPrimary 'br/public:avm/res/network/network-security-group:0.5.0' = [
//   for subnet in subnets[0]: if (enableNetworkSecurityGroups) {
//     scope: resourceGroup(resourceGroupName_Network[0])
//     name: 'nsgDeployment${subnet.name}'
//     params: {
//       name: toLower('${subnet.name}${nsgSuffix}')
//       tags: tags
//       location: locations[0]
//       securityRules: securityRules
//     }
//   }
// ]


// module modNetworkSecurityGroup './modules/networkSecurityGroup.bicep' = [
//   for i in range(0, length(locations)): if (enableNetworkSecurityGroups) {
//     scope: resourceGroup(resourceGroupName_Network[i])
//     name: 'nsgDeployment${i}'
//     params: {
//       resourceGroupName_Network: resourceGroupName_Network[i]
//       subnets: subnet
// virtualNetwork: virtualNetworks
//       tags: tags
//       location: locations
//       securityRules: securityRules
//       nsgSuffix: nsgSuffix
//     }
//     dependsOn: [
//       modResourceGroupNetwork
//     ]
//   }
// ]

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
      dnsServers: [] // ((enableFirewall) ? dnsFirewallProxy : dnsPrivateResolver)
      subnets: [
        for subnet in virtualNetwork[i].subnets: {
          name: subnet.name
          addressPrefix: subnet.addressPrefix
          delegation: subnet.delegation
          networkSecurityGroupResourceId: (subnet.name == 'AzureBastionSubnet' || subnet.name == 'GatewaySubnet')
            ? ''
            : toLower('/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[i]}/providers/Microsoft.Network/networkSecurityGroups/${subnet.name}${nsgSuffix}') //${virtualNetwork[i].name}-${subnet.name}${nsgSuffix}')
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
    scope: resourceGroup(resourceGroupName_PrivateDns[0])
    name: '${privatelinkDnsZoneName}Deployment'
    params: {
      name: privatelinkDnsZoneName
      tags: tags
      virtualNetworkLinks: [
        {
          registrationEnabled: false
          virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
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
    name: dnsResolverName
    location: locations[0]
    tags: tags
    inboundEndpoints: [
      (enableDnsResolver)
        ? {
            name: 'inboundEndpoint'
            subnetResourceId: modVirtualNetwork[0].outputs.subnetResourceIds[2]
          }
        : {}
    ]
    // outboundEndpoints: [
    //   (enableDnsResolver) ? {
    //     name: 'OutboundEndpoint'
    //     subnetResourceId: virtualNetwork.outputs.subnetResourceIds[3]
    //   } : {}
    // ]
    virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
  }
  dependsOn: [
    modPrivateDnsZones
    modVirtualNetwork
  ]
}

// Azure Bastion Host

module bastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = if (enableBastion) {
  scope: resourceGroup(resourceGroupName_Bastion[0])
  name: 'AzureBastionDeployment'
  params: {
    name: bastionName
    location: locations[0]
    virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
    tags: tags
    disableCopyPaste: disableCopyPaste
    enableIpConnect: enableIpConnect
    enableFileCopy: enableFileCopy
    scaleUnits: scaleUnits
    enableShareableLink: enableShareableLink
    skuName: skuName
  }
  dependsOn: [
    modVirtualNetwork
  ]
}

// Key Vault

module vault 'br/public:avm/res/key-vault/vault:0.9.0' = if (enableKeyVault) {
  scope: resourceGroup(resourceGroupName_Network[0])
  name: 'vaultDeployment'
  params: {
    name: keyVaultName
    accessPolicies: []
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
        workspaceResourceId: modWorkspace[0].outputs.resourceId
      }
    ]
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    keys: []
    location: locations[0]
    lock: {}
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    privateEndpoints: [
      {
        tags: tags
        customDnsConfigs: []
        name: '${keyVaultName}${peSuffix}'
        customNetworkInterfaceName: '${keyVaultName}${nicSuffix}'
        ipConfigurations: []
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones[0].outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
            }
          ]
        }
        roleAssignments: []
        subnetResourceId: modVirtualNetwork[0].outputs.subnetResourceIds[1]
      }
    ]
    roleAssignments: []
    secrets: []
    softDeleteRetentionInDays: 7
    tags: tags
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}
