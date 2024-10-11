targetScope = 'subscription'

param enableUserAssignedManagedIdentity bool
param enableVirtualHub bool
param enableVirtualWan bool
param enableAzureFirewall bool
param enableVpnSite bool
param enableVirtualNetworkGroup bool
param enablePrivatDnsZones bool
param enableDnsResolver bool
param enableVirtualNetwork bool
param enableFirewall bool
param enableBastion bool

param location string
param tags object

param subscriptionId string
// param coreCAFPrefixes string

param virtualNetworkName string
param virtualWanName string
param virtualWanSku string
param virtualHubName string
param uamiName string
param bastionName string
param dnsResolverName string
param vpnSiteName string
param resourceGroupNetworkName string
param resourceGroupBastionName string
param resourceGroupPrivateDnsName string
param defaultRoutesName string
param firewallName string
param firewallPolicyName string

param addressPrefixes array
param subnets array
param securityRules array

// VPN Gateway Site-to-Site

param vpnSiteLinks array

param ruleCollectionGroups array
param disableVpnEncryption bool
// param bgpSettings int
// param vpnGatewayScaleUnit int

// Virtual WAN

param allowVnetToVnetTraffic bool
param allowBranchToBranchTraffic bool

// Virtual WAN Hub

// param preferredRoutingGateway string
// param hubRoutingPreference string

// Azure DNS 

// param onPremDnsServer string
param dnsFirewallProxy array
param dnsPrivateResolver array
// param inboundEndpoints string
// param outboundEndpoints string

// aram tenantId string = tenant().tenantId

param primaryRegionName string
param secondaryRegionName string

param firewallTier string
param numberOfPublicIPs int

param disableCopyPaste bool
param enableFileCopy bool
param enableIpConnect bool
param enableShareableLink bool

// param enableTunneling bool
// param privateIPAllocationMethod string
param scaleUnits int

param privatelinkDnsZoneNames array

param roleAssignmentsNetwork array
param roleAssignmentsBastion array
param roleAssignmentsPrivateDns array
param lock object

// Resource Groups

module resourceGroupNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupNetworkDeployment'
  params: {
    name: resourceGroupNetworkName
    tags: tags
    location: primaryRegionName
    lock: lock
    roleAssignments: roleAssignmentsNetwork
  }
}

module resourceGroupBastion 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupBastionDeployment'
  params: {
    name: resourceGroupBastionName
    tags: tags
    location: primaryRegionName
    lock: lock
    roleAssignments: roleAssignmentsBastion
  }
}

module resourceGroupDnsZones 'br/public:avm/res/resources/resource-group:0.4.0' = {
  scope: subscription(subscriptionId)
  name: 'resourceGroupDnsZonesDeployment'
  params: {
    name: resourceGroupPrivateDnsName
    tags: tags
    lock: lock
    roleAssignments: roleAssignmentsPrivateDns
  }
}

// User Assigned Managed Identity

module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = if (enableUserAssignedManagedIdentity == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'userAssignedIdentityDeployment'
  params: {
    name: uamiName
    tags: tags
    location: primaryRegionName
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Virtual WAN

module virtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = if (enableVirtualWan == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'virtualWanDeployment'
  params: {
    name: virtualWanName
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    location: location
    tags: tags
    type: virtualWanSku // 'Basic' | Standard
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Virtual WAN Hub

module virtualHub 'br/public:avm/res/network/virtual-hub:0.2.2' = if (enableVirtualHub == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'virtualHubDeployment'
  params: {
    addressPrefix: '10.0.0.0/23' // addressPrefix
    name: virtualHubName
    virtualWanId: virtualWan.outputs.resourceId
    hubRouteTables: [
      {
        name: defaultRoutesName
      }
    ]
    hubVirtualNetworkConnections: [
      {
        name: 'connection1'
        remoteVirtualNetworkId: virtualNetwork.outputs.resourceId
        routingConfiguration: {
          associatedRouteTable: {
            id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualWanName, defaultRoutesName)
          }
          propagatedRouteTables: {
            ids: [
              {
                id: resourceId('Microsoft.Network/virtualHubs/hubRouteTables', virtualWanName, defaultRoutesName)
              }
            ]
            labels: [
              'default'
            ]
          }
        }
      }
    ]
    location: primaryRegionName
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Firewall Policy

module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.3' = if (enableAzureFirewall == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'firewallPolicyDeployment'
  params: {
    name: firewallPolicyName
    tags: tags
    allowSqlRedirect: true
    autoLearnPrivateRanges: 'Enabled'
    location: primaryRegionName
    managedIdentities: {
      userAssignedResourceIds: [
        userAssignedIdentity.outputs.resourceId
      ]
    }
    mode: 'Alert'
    ruleCollectionGroups: ruleCollectionGroups
    tier: firewallTier
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Azure Firewall

module azureFirewall 'br/public:avm/res/network/azure-firewall:0.5.0' = if (enableAzureFirewall == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'azureFirewallDeployment'
  params: {
    name: firewallName
    tags: tags
    firewallPolicyId: firewallPolicy.outputs.resourceId
    hubIPAddresses: {
      publicIPs: {
        count: numberOfPublicIPs
      }
    }
    location: primaryRegionName
    virtualHubId: virtualHub.outputs.resourceId
  }
  dependsOn: [
    resourceGroupNetwork
    virtualHub
    firewallPolicy
  ]
}

// VPN Site

module vpnSite 'br/public:avm/res/network/vpn-site:0.3.0' = if (enableVpnSite == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'vpnSiteDeployment'
  params: {
    name: vpnSiteName
    location: primaryRegionName
    tags: tags
    virtualWanId: virtualWan.outputs.resourceId
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
    resourceGroupNetwork
    virtualWan
    virtualHub
  ]
}

// Network Security Group

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = if (enableVirtualNetworkGroup == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'networkSecurityGroupDeployment'
  params: {
    name: 'nnsgmax001'
    tags: tags
    location: location
    securityRules: securityRules
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Virtual Network

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = if (enableVirtualNetwork == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'virtualNetworkDeployment'
  params: {
    name: virtualNetworkName
    location: location
    tags: tags
    addressPrefixes: addressPrefixes
    dnsServers: ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver)
    subnets: subnets
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Private DNS Zones

module privateDnsZones 'br/public:avm/res/network/private-dns-zone:0.6.0' = if (enablePrivatDnsZones == true) {
  scope: resourceGroup(resourceGroupDnsZones.name)
  name: 'privateDnsZonesDeployment'
  params: {
    name: privatelinkDnsZoneNames[0]
    tags: tags
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
      }
    ]
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// DNS Private Resolver

module dnsResolver 'br/public:avm/res/network/dns-resolver:0.5.0' = if (enableDnsResolver == true) {
  scope: resourceGroup(resourceGroupNetworkName)
  name: 'DnsResolverDeployment'
  params: {
    name: dnsResolverName
    location: location
    tags: tags
    inboundEndpoints: [
      {
        name: 'inboundEndpoint'
        subnetResourceId: virtualNetwork.outputs.subnetNames[2]
      }
    ]
    outboundEndpoints: [
      {
        name: 'inboundEndpoint'
        subnetResourceId: virtualNetwork.outputs.subnetNames[3]
      }
    ]
    
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
  }
  dependsOn: [
    virtualNetwork
  ]
}

// Azure Bastion Host

module bastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = if (enableBastion == true) {
  scope: resourceGroup(resourceGroupBastion.name)
  name: 'AzureBastionDeployment'
  params: {
    name: bastionName
    location: location
    tags: tags
    disableCopyPaste: disableCopyPaste
    enableIpConnect: enableIpConnect
    enableFileCopy: enableFileCopy
    scaleUnits: scaleUnits
    enableShareableLink: enableShareableLink
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
    skuName: 'Standard'
  }
  dependsOn: [
    virtualNetwork
  ]
}

// Virtual Network Connections initiated from VWAN

// module coreHubToCore 'network/virtualWanHubPeering.bicep' = {
//   scope: resourceGroup(vwanHubSubscriptionIds[0], '${vwanHubCAFPrefixes[0]}networkrg')
//   name: '${coreCAFPrefixes}hub-to-${coreCAFPrefixes}vnet'
//   params: {
//     coreSubscriptionIds: coreSubscriptionIds
//     virtualNetworkSpokeName: virtualNetworkCore.outputs.virtualNetworkNameCore
//     virtualWanHubName: '${coreCAFPrefixes}hub'
//     virtualNetworkSpokeId: virtualNetworkCore.outputs.virtualNetworkIdCore
//     location: coreLocations
//   }
//   dependsOn: [
//     virtualNetworkCore
//   ]
// }
