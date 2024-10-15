param location string
param tags object
param vwanSKUType string
param vwanCAFPrefixes string
param disableVpnEncryption bool
param allowVnetToVnetTraffic bool
param allowBranchToBranchTraffic bool

param vwanHubCAFPrefixes array
param vwanHubAddressSpaces array
param vwanHubLocations array
param vwanHubSubscriptionIds array

param preferredRoutingGateway string
param hubRoutingPreference string

param enableVPNGateway bool
param bgpSettings int
param vpnGatewayScaleUnit int

// Azure Firewall
param enableFirewall bool
param firewallTier string
param numberOfPublicIPs int
param onPremDNSServer string

// Virtual WAN

resource virtualWan 'Microsoft.Network/virtualWans@2020-11-01' = {
  name: '${vwanCAFPrefixes}vwan'
  location: location
  tags: tags
  properties: {
    disableVpnEncryption: disableVpnEncryption
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    type: vwanSKUType
  }
  dependsOn: [
  ]
}

// Virtual WAN Hub

module virtualWanHub 'virtualWanHub.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): {
  name: 'subVirtualWan.bicep.virtualWanHub${i}'
  params: {
    hubRoutingPreference: hubRoutingPreference
    preferredRoutingGateway: preferredRoutingGateway
    vwanHubAddressSpaces: vwanHubAddressSpaces[i]
    vwanHubCAFPrefixes: vwanHubCAFPrefixes[i]
    virtualWanId: virtualWan.id // virtualWan.outputs.virtualWanId
    location: vwanHubLocations[i]
    tags: tags
  }
  dependsOn: [
  ]
}]

// Virtual WAN / Site-to-Site Gateway

module virtualWanGatewayS2S 'virtualWanHubGatewayS2S.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): if (enableVPNGateway == true) {
  name: 'subNetworkCore.bicep.virtualWanHubGWS2S${i}'
  params: {
    bgpSettings: bgpSettings
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    virtualWanHubId: virtualWanHub[i].outputs.virtualWanHubId
    virtualWanHubName: virtualWanHub[i].outputs.virtualWanHubName
    location: vwanHubLocations[i]
  }
  dependsOn: [
    virtualWan
    virtualWanHub
  ]
}]

// Azure Firewall

module azureFirewall 'azureFirewall.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): if (enableFirewall == true) {
  name: 'subNetworkCore.bicep.AZFW.${i}'
  params: {
    onPremDNSServer: onPremDNSServer
    coreCAFPrefixes: vwanHubCAFPrefixes[i]
    virtualHubId: virtualWanHub[i].outputs.virtualWanHubId
    tier: firewallTier
    numberOfPublicIPs: numberOfPublicIPs
    location: vwanHubLocations[i]
  }
  dependsOn: [
    virtualWan
    virtualWanHub
  ]
}]

// Azure Firewall / Policy Stub

module azureFirewallPolicy 'azureFirewallPolicy.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): if (enableFirewall == true) {
  name: 'subNetworkCore.bicep.AZFWPolicyStub.${i}'
  params: {
    coreCAFPrefixes: vwanHubCAFPrefixes[i]
    location: vwanHubLocations[i]
  }
  dependsOn: [
    azureFirewall
  ]
}]

// Azure Firewall / Network Policy

module azureFirewallPolicyNetwork 'azureFirewallPolicyNetwork.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): if (enableFirewall == true) {
  name: 'subNetworkCore.bicep.AZFWPolicyNetwork.${i}'
  params: {
    coreCAFPrefixes: vwanHubCAFPrefixes[i]
    location: vwanHubLocations[i]
  }
  dependsOn: [
    azureFirewall
    azureFirewallPolicy
  ]
}]

// Azure Firewall / DNAT Policy

module azureFirewallPolicyDNAT 'azureFirewallPolicyDnat.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): if (enableFirewall == true) {
  name: 'subNetworkCore.bicep.AZFWPolicyDNAT.${i}'
  params: {
    coreCAFPrefixes: vwanHubCAFPrefixes[i]
    location: vwanHubLocations[i]
  }
  dependsOn: [
    azureFirewall
    azureFirewallPolicy
    azureFirewallPolicyNetwork
  ]
}]

// Azure Firewall / Application Policy

module azureFirewallPolicyApplication 'azureFirewallPolicyApplication.bicep' = [for i in range(0, length(vwanHubSubscriptionIds)): if (enableFirewall == true) {
  name: 'subNetworkCore.bicep.AZFWPolicyApplication.${i}'
  params: {
    coreCAFPrefixes: vwanHubCAFPrefixes[i]
    location: vwanHubLocations[i]
  }
  dependsOn: [
    azureFirewall
    azureFirewallPolicy
    azureFirewallPolicyNetwork
    azureFirewallPolicyDNAT
  ]
}]
