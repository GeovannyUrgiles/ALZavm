targetScope = 'subscription'

// Deployment Boolean Parameters

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

// Virtual Hub Connectivity

param spokes array

// Deployment Options

param location array
param tags object

param subscriptionId string

// Resource Names

param virtualNetworkName string
param virtualWanName string
param virtualWanSku string
param virtualHubName string
param uamiName string
param bastionName string
param dnsResolverName string
param vpnSiteName string

param firewallName string
param firewallPolicyName string

// Resource Group Parameters

param resourceGroupName_Network string
param resourceGroupName_Bastion string
param resourceGroupName_PrivateDns string
param roleAssignmentsNetwork array
param roleAssignmentsBastion array
param roleAssignmentsPrivateDns array
param lock object

// Virtual Network Parameters

param addressPrefixes array
param subnets array
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

module resourceGroupNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = {
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

module resourceGroupBastion 'br/public:avm/res/resources/resource-group:0.4.0' = {
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

module resourceGroupDnsZones 'br/public:avm/res/resources/resource-group:0.4.0' = {
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

module userAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = if (enableUserAssignedManagedIdentity == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'userAssignedIdentityDeployment'
  params: {
    name: uamiName
    tags: tags
    location: location[0]
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Virtual WAN

module virtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = if (enableVirtualWan == true) {
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
    resourceGroupNetwork
  ]
}

// Virtual WAN Hub

module virtualHub 'br/public:avm/res/network/virtual-hub:0.2.2' = if (enableVirtualHub == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'virtualHubDeployment'
  params: {
    addressPrefix: addressPrefix
    name: virtualHubName
    virtualWanId: virtualWan.outputs.resourceId
    hubRouteTables: [
      {
        name: defaultRoutesName
      }
   ]
    hubVirtualNetworkConnections: [ // for spoke in spokes: {
      {
        name: '${virtualNetworkName}-to-${virtualHubName}'
        remoteVirtualNetworkId: virtualNetwork.outputs.resourceId // /subscription/${spoke.sub}/resourceGroups/${spoke.rg}/providers/Microsoft.Network/virtualNetworks/${spoke.vnet}
        routingConfiguration: {
          associatedRouteTable: {
            id: '${resourceGroupNetwork.outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${defaultRoutesName}'
          }
          propagatedRouteTables: {
            ids: [
              {
                id: '${resourceGroupNetwork.outputs.resourceId}/providers/Microsoft.Network/virtualHubs/${virtualHubName}/hubRouteTables/${defaultRoutesName}'
              }
            ]
            labels: [
              'none'
            ]
          }
        }
      }
    ]
    location: location[0]
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Firewall Policy

module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.3' = if (enableAzureFirewall == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'firewallPolicyDeployment'
  params: {
    name: firewallPolicyName
    tags: tags
    // allowSqlRedirect: true
    // autoLearnPrivateRanges: 'Enabled'
    location: location[0]
    // managedIdentities: {
    //   userAssignedResourceIds: [
    //     userAssignedIdentity.outputs.resourceId
    //   ]
    // }
    // mode: mode 
    ruleCollectionGroups: ruleCollectionGroups
    tier: 'Standard' // tier
  }
  dependsOn: [
    virtualHub
  ]
}

// Azure Firewall

module azureFirewall 'br/public:avm/res/network/azure-firewall:0.5.0' = if (enableAzureFirewall == true) {
  scope: resourceGroup(resourceGroupName_Network)
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
    location: location[0]
    virtualHubId: virtualHub.outputs.resourceId
  }
  dependsOn: [
    firewallPolicy
  ]
}

// VPN Site

module vpnSite 'br/public:avm/res/network/vpn-site:0.3.0' = if (enableVpnSite == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'vpnSiteDeployment'
  params: {
    name: vpnSiteName
    location: location[0]
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
    virtualHub
  ]
}

// Network Security Group

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = if (enableVirtualNetworkGroup == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'networkSecurityGroupDeployment'
  params: {
    name: 'nnsgmax001'
    tags: tags
    location: location[0]
    securityRules: securityRules
  }
  dependsOn: [
    resourceGroupNetwork
  ]
}

// Virtual Network

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = if (enableVirtualNetwork == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'virtualNetworkDeployment'
  params: {
    name: virtualNetworkName
    location: location[0]
    tags: tags
    addressPrefixes: addressPrefixes
    dnsServers: [] // ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver)
    subnets: subnets
  }
  dependsOn: [
    resourceGroupNetwork
    networkSecurityGroup
  ]
}

// Private DNS Zones

module privateDnsZones 'br/public:avm/res/network/private-dns-zone:0.6.0' = [for privatelinkDnsZoneName in privatelinkDnsZoneNames: if (enablePrivatDnsZones == true) {
  scope: resourceGroup(resourceGroupName_PrivateDns)
  name: '${privatelinkDnsZoneName}Deployment'
  params: {
    name: privatelinkDnsZoneName
    tags: tags
    virtualNetworkLinks: [
      {
        registrationEnabled: false
        virtualNetworkResourceId: virtualNetwork.outputs.resourceId
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}
]

// DNS Private Resolver

module dnsResolver 'br/public:avm/res/network/dns-resolver:0.5.0' = if (enableDnsResolver == true) {
  scope: resourceGroup(resourceGroupName_Network)
  name: 'DnsResolverDeployment'
  params: {
    name: dnsResolverName
    location: location[0]
    tags: tags
    inboundEndpoints: [
      {
        name: 'inboundEndpoint'
        subnetResourceId: virtualNetwork.outputs.subnetResourceIds[2]
      }
    ]
    // outboundEndpoints: [
    //   {
    //     name: 'OutboundEndpoint'
    //     subnetResourceId: virtualNetwork.outputs.subnetResourceIds[3]
    //   }
    // ]
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
  }
  dependsOn: [
    privateDnsZones
    virtualNetwork
  ]
}

// Azure Bastion Host

module bastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = if (enableBastion == true) {
  scope: resourceGroup(resourceGroupName_Bastion)
  name: 'AzureBastionDeployment'
  params: {
    name: bastionName
    location: location[0]
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
    tags: tags
    disableCopyPaste: disableCopyPaste
    enableIpConnect: enableIpConnect
    enableFileCopy: enableFileCopy
    scaleUnits: scaleUnits
    enableShareableLink: enableShareableLink
    
    skuName: skuName
  }
  dependsOn: [
    virtualNetwork
  ]
}
