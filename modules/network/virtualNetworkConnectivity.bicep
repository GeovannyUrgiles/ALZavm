// param dnsServers array
param subnets array
param addressSpace string
param location string
param tags object
param CAFPrefix string

resource virtualnetworkscore 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: '${CAFPrefix}vnet'
  location: location
  tags: tags
  properties: {
    subnets: [for subnet in subnets: {
      name: subnet.name
      // if subnetcore.name is AzureVNIxxx then delegate
      properties: subnet.name == 'AzureDNSInboundSubnet' ? {
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
        // if subnetcore.name is AzureDNSOutboundSubnet then delegate
      } : subnet.name == 'AzureDNSOutboundSubnet' ? {
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Network/dnsResolvers'
            }
          }
        ]
        // else 
      } : {
        addressPrefix: subnet.subnetPrefix
      }
    }]
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    dhcpOptions: {
      // dnsServers: dnsServers
    }
  }
  dependsOn: [
  ]
}

output virtualNetworkNameCore string = virtualnetworkscore.name
output virtualNetworkIdCore string = virtualnetworkscore.id
output bastionSubnetNameCore string = virtualnetworkscore.properties.subnets[0].name
output bastionSubIdCore string = virtualnetworkscore.properties.subnets[0].id
output dnsInboundSubnetNameCore string = virtualnetworkscore.properties.subnets[1].name
output dnsInboundSubIdCore string = virtualnetworkscore.properties.subnets[1].id
output dnsOutboundSubnetNameCore string = virtualnetworkscore.properties.subnets[2].name
output dnsOutboundSubIdCore string = virtualnetworkscore.properties.subnets[2].id
output activeDirectorySubnetNameCore string = virtualnetworkscore.properties.subnets[3].name
output activeDirectorySubIdCore string = virtualnetworkscore.properties.subnets[3].id
output pepSubnetNameCore string = virtualnetworkscore.properties.subnets[4].name
output pepSubnetIdCore string = virtualnetworkscore.properties.subnets[4].id
// output vniSubnetNameCore_CloudControl string = virtualnetworkscore.properties.subnets[5].name
// output vniSubnetIdCore_CloudControl string = virtualnetworkscore.properties.subnets[5].id
// output vniSubnetNameCore_fnapp01 string = virtualnetworkscore.properties.subnets[6].name
// output vniSubnetIdCore_fnapp01 string = virtualnetworkscore.properties.subnets[6].id
