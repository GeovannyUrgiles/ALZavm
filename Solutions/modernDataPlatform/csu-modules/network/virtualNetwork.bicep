param dnsServers array
param nsgRules array
param subnets array
param spokeAddressSpace string
param location string
param virtualNetworkName string
param functionAppSubnetName string
param endpointSubnetName string

param tags object

resource networkSecurityGroups 'Microsoft.Network/networkSecurityGroups@2024-01-01' = [
  for subnet in subnets: {
    name: '${toLower(virtualNetworkName)}-${toLower(subnet.name)}-nsg'
    location: location
    tags: tags
    properties: {
      securityRules: nsgRules
    }
  }
]

//  

resource virtualNetworksSpoke 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: subnet.name == functionAppSubnetName
          ? {
              networkSecurityGroup: {
                id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${virtualNetworkName}-${subnet.name}-nsg')
              }
              addressPrefix: subnet.subnetPrefix
              delegations: [
                {
                  name: 'delegation'
                  properties: {
                    serviceName: 'Microsoft.Web/serverFarms'
                  }
                }
              ]
            }
          : subnet.name == endpointSubnetName
          ? {
              networkSecurityGroup: {
                id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${virtualNetworkName}-${subnet.name}-nsg')
              }
              addressPrefix: subnet.subnetPrefix
              serviceEndpoints: [
                {
                  locations: [
                    '*'
                  ]
                    service: 'Microsoft.KeyVault'
                }
              ]
          // else 
                }
          : {
              networkSecurityGroup: {
                id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${virtualNetworkName}-${subnet.name}-nsg')
                  }
              addressPrefix: subnet.subnetPrefix
            }
      }
    ]
    addressSpace: {
      addressPrefixes: [
        spokeAddressSpace
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
  }
  dependsOn: [
    networkSecurityGroups
  ]
}

output virtualNetworkNameSpoke string = virtualNetworksSpoke.name
output virtualNetworkConnectionSpoke string = virtualNetworksSpoke.name
output virtualNetworkIdSpoke string = virtualNetworksSpoke.id
