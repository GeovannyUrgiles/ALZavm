targetScope = 'subscription'

// Deployment Boolean Parameters

param enableUserAssignedManagedIdentity bool
param enableVirtualHub bool
param enableVirtualWan bool
param enableAzureFirewall bool
param enableVpnSite bool
param enableNetworkSecurityGroups bool
param enablePrivatDnsZones bool
param enableDnsResolver bool
param enableVirtualNetwork bool
param enableBastion bool
param enableOperationalInsightsName bool
param enableVpnGateway bool

// Virtual Hub Connectivity

param spokes array

// Deployment Options

param subscriptionId string
param location array
param tags object


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

// Resource Group Parameters

param resourceGroupName_Network string
param resourceGroupName_Bastion string
param resourceGroupName_PrivateDns string
param roleAssignmentsNetwork array
param roleAssignmentsBastion array
param roleAssignmentsPrivateDns array
param lock object

// Virtual Network Parameters

param virtualNetwork object
param addressPrefixes array
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

// Azure Firewall Parameters

param tier string
param numberOfPublicIPs int
// param enableTunneling bool
// param privateIPAllocationMethod string
param scaleUnits int
param ruleCollectionGroups array
param disableVpnEncryption bool
// param bgpSettings int
// param vpnGatewayScaleUnit int
param mode string

// Private DNS Parameters

param privatelinkDnsZoneNames array

// Bastion Parameters

param skuName string
param disableCopyPaste bool
param enableFileCopy bool
param enableIpConnect bool
param enableShareableLink bool

// Network Resource Group Deployment

module modResourceGroupNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupNetworkDeployment'
  params: {
    name: resourceGroupName_Network
    tags: tags
    location: location[0]
    // lock: lock
    roleAssignments: roleAssignmentsNetwork
  }
}

// Bastion  Resource Group Deployment

module modResourceGroupBastion 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupBastionDeployment'
  params: {
    name: resourceGroupName_Bastion
    tags: tags
    location: location[0]
    // lock: lock
    roleAssignments: roleAssignmentsBastion
  }
}

// Private DNS Resource Group Deployment

module modResourceGroupDnsZones 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupDnsZonesDeployment'
  params: {
    name: resourceGroupName_PrivateDns
    tags: tags
    // lock: lock
    roleAssignments: roleAssignmentsPrivateDns
  }
}

// User Assigned Managed Identity

module modUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = if (enableUserAssignedManagedIdentity) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'userAssignedIdentityDeployment'
  params: {
    name: uamiName
    tags: tags
    location: location[0]
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// Operational Insights

module modWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = if (enableOperationalInsightsName) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'workspaceDeployment'
  params: {
    name: operationalInsightsName
    location: location[0]
  }
}

// Virtual WAN

module modVirtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = if (enableVirtualWan) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'virtualWanDeployment'
  params: {
    name: virtualWanName
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    location: location[0]
    tags: tags
    type: virtualWanSku
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// Virtual WAN Hub

module modVirtualHub 'br/public:avm/res/network/virtual-hub:0.2.2' = if (enableVirtualHub) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'virtualHubDeployment'
  params: {
    addressPrefix: addressPrefix
    name: virtualHubName
    virtualWanId: modVirtualWan.outputs.resourceId
    hubRouteTables: [
      {
        name: defaultRoutesName
      }
    ]
    hubVirtualNetworkConnections: [
      // for spoke in spokes: {
      {
        name: '${virtualNetworkName}-to-${virtualHubName}'
        remoteVirtualNetworkId: modVirtualNetwork.outputs.resourceId // /subscription/${spoke.sub}/resourceGroups/${spoke.rg}/providers/Microsoft.Network/virtualNetworks/${spoke.vnet}
        routingConfiguration: {
          associatedRouteTable: {
            id: '${modResourceGroupNetwork.outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${defaultRoutesName}'
          }
          propagatedRouteTables: {
            ids: [
              {
                id: '${modResourceGroupNetwork.outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${defaultRoutesName}'
              }
            ]
            labels: [
              defaultRoutesName
            ]
          }
        }
      }
    ]
    location: location[0]
  }
  dependsOn: [
    modResourceGroupNetwork
  ]
}

// VPN Gateway for Site-to-Site, Point-to-Site or VWAN-to-VWAN

module modVpnGateway 'br/public:avm/res/network/vpn-gateway:0.1.3' = if (enableVpnGateway) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'vpnGatewayDeployment'
  params: {
    name: vpnGatewayName
    virtualHubResourceId: modVirtualHub.outputs.resourceId
    location: location[0]
  }
  dependsOn: [
    modVirtualHub
  ]
}

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
  scope: resourceGroup(resourceGroupName_Network)
  name: 'firewallPolicyDeployment'
  params: {
    name: firewallPolicyName
    tags: tags
    allowSqlRedirect:  (tier == 'Premium') ? true : false
    autoLearnPrivateRanges: (tier == 'Premium') ? 'Enabled' : 'Disabled'
    location: location[0]

    // identity: identity

    managedIdentities: {
      userAssignedResourceIds: [
        modUserAssignedIdentity.outputs.resourceId
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
  scope: resourceGroup(resourceGroupName_Network)
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
    location: location[0]
    virtualHubId: modVirtualHub.outputs.resourceId
  }
  dependsOn: [
    modFirewallPolicy
  ]
}

// VPN Gateway Site-to-Site

// resource virtualwangateways2s 'Microsoft.Network/vpnGateways@2021-05-01' = {
//   scope: resourceGroup(resourceGroupName_Network)
//   name: '${vwanHubName}s2sgw'
//   location: location
//   properties: {
//     vpnGatewayScaleUnit: vpnGatewayScaleUnit
//     isRoutingPreferenceInternet: false
//     bgpSettings: {
//       asn: bgpSettings
//     }
//     virtualHub: {
//       id: virtualHub.outputs.resourceId
//     }
//   }
// }

// VPN Site for VWAN-to-VWAN connections

module vpnSite 'br/public:avm/res/network/vpn-site:0.3.0' = if (enableVpnSite) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'vpnSiteDeployment'
  params: {
    name: vpnSiteName
    location: location[0]
    tags: tags
    virtualWanId: modVirtualWan.outputs.resourceId
    deviceProperties: {
      linkSpeedInMbps: 0
    }
    o365Policy: {
      breakOutCategories: {
        allow: true
        default: true
        optimize: true
      }
    }
    vpnSiteLinks: vpnSiteLinks
  }
  dependsOn: [
    modVirtualHub
  ]
}

// Network Security Group

module modNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = [ for subnet in virtualNetwork.subnets: if (enableNetworkSecurityGroups) {
    scope: resourceGroup(resourceGroupName_Network)
    name: 'nsg${subnet.name}Deployment'
    params: {
      name: toLower('${subnet.name}-nsg')
      tags: tags
      location: location[0]
      securityRules: securityRules
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Virtual Network

module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = if (enableVirtualNetwork) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'virtualNetworkDeployment'
  params: {
    name: virtualNetworkName
    location: location[0]
    tags: tags
    addressPrefixes: addressPrefixes
    dnsServers: [] // ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver)
    subnets: [for subnet in virtualNetwork.subnets: {
      name: subnet.name
      addressPrefix: subnet.addressPrefix
      networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network}/providers/Microsoft.Network/networkSecurityGroups/${subnet.name}-nsg'
      }
    ]
  }
  dependsOn: [
    modResourceGroupNetwork
    modNetworkSecurityGroup
  ]
}

// Private DNS Zones

module modPrivateDnsZones 'br/public:avm/res/network/private-dns-zone:0.6.0' = [ for privatelinkDnsZoneName in privatelinkDnsZoneNames: if (enablePrivatDnsZones) {
    scope: resourceGroup(resourceGroupName_PrivateDns)
    name: '${privatelinkDnsZoneName}Deployment'
    params: {
      name: privatelinkDnsZoneName
      tags: tags
      virtualNetworkLinks: [
        {
          registrationEnabled: false
          virtualNetworkResourceId: modVirtualNetwork.outputs.resourceId
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
  scope: resourceGroup(resourceGroupName_Network)
  name: 'DnsResolverDeployment'
  params: {
    name: dnsResolverName
    location: location[0]
    tags: tags
    inboundEndpoints: [
      {
        name: 'inboundEndpoint'
        subnetResourceId: modVirtualNetwork.outputs.subnetResourceIds[2]
      }
    ]
    // outboundEndpoints: [
    //   {
    //     name: 'OutboundEndpoint'
    //     subnetResourceId: virtualNetwork.outputs.subnetResourceIds[3]
    //   }
    // ]
    virtualNetworkResourceId: modVirtualNetwork.outputs.resourceId
  }
  dependsOn: [
    modPrivateDnsZones
    modVirtualNetwork
  ]
}

// Azure Bastion Host

module bastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = if (enableBastion) {
  scope: resourceGroup(resourceGroupName_Bastion)
  name: 'AzureBastionDeployment'
  params: {
    name: bastionName
    location: location[0]
    virtualNetworkResourceId: modVirtualNetwork.outputs.resourceId
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
