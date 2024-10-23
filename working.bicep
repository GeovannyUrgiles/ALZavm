param dnsForwardingRulesets_fr_name string = 'fr'
param dnsResolvers_conwus2dns_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/dnsResolvers/conwus2dns'
param virtualNetworks_conwus2vnet_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualNetworks/conwus2vnet'

resource dnsForwardingRulesets_fr_name_resource 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: dnsForwardingRulesets_fr_name
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: '${dnsResolvers_conwus2dns_externalid}/outboundEndpoints/OutboundEndpoint'
      }
    ]
  }
}

resource dnsForwardingRulesets_fr_name_conwus2vnet_link 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: dnsForwardingRulesets_fr_name_resource
  name: 'conwus2vnet-link'
  properties: {
    virtualNetwork: {
      id: virtualNetworks_conwus2vnet_externalid
    }
  }
}
