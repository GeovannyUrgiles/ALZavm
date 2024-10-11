targetScope = 'subscription'

param nsgRules array
param location string
param tags object

// Preconfigured Array - retain mandatory .254 Private Endpoint subnet, edit to need

param subnetsSpokePreconfigured array = [
  // Azure VM Subnet
  {
    name: 'virtualMachineSN01'
    subnetPrefix: '${spokeCIDRPrefix}.0.0/24'
  }
  // Azure PrivateEndpoint Subnet
  {
    name: 'privateEndpointSN01'
    subnetPrefix: '${spokeCIDRPrefix}.1.0/24'
  }
  // Virtual Network Integration / 01
  {
    name: 'functionAppSN01'
    subnetPrefix: '${spokeCIDRPrefix}.2.0/27'
  }
  // Virtual Network Integration / 02
  {
    name: 'webAppSN01'
    subnetPrefix: '${spokeCIDRPrefix}.2.32/27'
  }
  ]
// Resource Group

resource resourceGroupNetworkSpoke 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${virtualNetworkName}networkrg'
  location: location
  tags: tags
  dependsOn: [
  ]
}

// Virtual Network Spokes

module virtualNetworkSpoke 'network/virtualNetworks.bicep' = {
  scope: resourceGroupNetworkSpoke
  name: '${virtualNetworkName}vnet'
  params: {
    servicePrincipalAppId: servicePrincipalAppId
    spokeSubscriptionIds: spokeSubscriptionIds
    nsgRules: nsgRules
    spokeAddressSpaces: spokeAddressSpaces
    virtualNetworkName: virtualNetworkName
    dnsServers: ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver) 
    location: location
    subnets: ((enableSpokeSubnets == true) ? subnetsSpokePreconfigured : subnetsSpoke) 
    tags: tags
  }
  dependsOn: [
  ]
}

output virtualNetworkSpokeName string = virtualNetworkSpoke.outputs.virtualNetworkNameSpoke
output virtualNetworkSpokeId string = virtualNetworkSpoke.outputs.virtualNetworkIdSpoke
