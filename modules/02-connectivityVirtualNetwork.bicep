targetScope = 'subscription'

param tags object

// connectivity Arrays
param connectivityNetworkResourceGroupName string
param connectivityAddressSpace string = '10.200.0.0/16'
param connectivityCIDRPrefix string = '10.200'
param CAFPrefix string
param location string


// DNS Private Resolver Subnet Names [shouldn't change]

param DNSInboundSubnetName string = 'AzureDNSInboundSubnet'
param DNSOutboundSubnetName string = 'AzureDNSOutboundSubnet'

// Network Security Group Defaults

// param nsgRules array = [
// ]

// Subnets / connectivity [Hub] Networks

param subnets array = [
  // Azure Bastion Subnet
  {
    name: 'AzureBastionSubnet'
    subnetPrefix: '${connectivityCIDRPrefix}.0.0/26'
  }
  // Azure DNS Resolver / Inbound Subnet
  {
    name: DNSInboundSubnetName
    subnetPrefix: '${connectivityCIDRPrefix}.1.0/24'
  }
  // Azure DNS Resolver / Outbound Subnet
  {
    name: DNSOutboundSubnetName
    subnetPrefix: '${connectivityCIDRPrefix}.2.0/24'
  }
  {
    name: 'AzureActiveDirectorySubnet'
    subnetPrefix: '${connectivityCIDRPrefix}.3.0/24'
  }
  // Azure PrivateEndpoint Subnet
  {
    name: 'AzureVirtualMachineSubnet'
    subnetPrefix: '${connectivityCIDRPrefix}.5.0/24'
  }
  // Azure PrivateEndpoint Subnet
  {
    name: 'AzurePrivateEndpointSubnet'
    subnetPrefix: '${connectivityCIDRPrefix}.254.0/23'
  }
]

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: connectivityNetworkResourceGroupName
}

// connectivity Virtual Network - Primary Region
module virtualNetworkconnectivity 'network/virtualNetworkConnectivity.bicep' = {
  scope: resourceGroup
  name: 'connectivityVirtualNetwork'
  params: {
    addressSpace: connectivityAddressSpace
    CAFPrefix: CAFPrefix
    location: location
    // dnsServers: '' // ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver)
    subnets: subnets
    tags: tags
  }
  dependsOn: [
  ]
}
