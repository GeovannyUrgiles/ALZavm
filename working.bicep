param dnsResolvers_hub_resolver_wus2_dns_name string = 'hub-resolver-wus2-dns'
param virtualNetworks_hub_wus2_vnet_01_externalid string = '/subscriptions/52ee1c04-98f8-4b57-a8e0-374872490778/resourceGroups/hub-network-wus2-rg/providers/Microsoft.Network/virtualNetworks/hub-wus2-vnet-01'

resource dnsResolvers_hub_resolver_wus2_dns_name_resource 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: dnsResolvers_hub_resolver_wus2_dns_name
  location: 'westus2'
  properties: {
    virtualNetwork: {
      id: virtualNetworks_hub_wus2_vnet_01_externalid
    }
  }
}

resource dnsResolvers_hub_resolver_wus2_dns_name_dns_inbound 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: dnsResolvers_hub_resolver_wus2_dns_name_resource
  name: 'dns-inbound'
  location: 'westus2'
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: '${virtualNetworks_hub_wus2_vnet_01_externalid}/subnets/dnsInboundSN01'
        }
        privateIpAddress: '10.152.41.68'
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
}
