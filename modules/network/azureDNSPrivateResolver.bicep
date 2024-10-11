param virtualNetworkId string
param location string
param AzureDNSInboundSubnet string
param AzureDNSOutboundSubnet string
param coreCAFPrefixes string


resource dnsresolvers 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = {
  name: '${coreCAFPrefixes}dns'
  location: location
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}

resource inboundendpoints 'Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview' = {
  parent: dnsresolvers
  name: 'DnsInboundRequests'
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: '${virtualNetworkId}/subnets/${AzureDNSInboundSubnet}'
        }
        privateIpAllocationMethod: 'Dynamic'
      }
    ]
  }
  dependsOn: [
    
  ]
}

resource outboundendpoints 'Microsoft.Network/dnsResolvers/outboundEndpoints@2020-04-01-preview' = {
  parent: dnsresolvers
  name: 'DnsOutboundForwarders'
  location: location
  properties: {
    subnet: {
      id: '${virtualNetworkId}/subnets/${AzureDNSOutboundSubnet}'
    }
  }
  dependsOn: [
    
  ]
}

output dnsResolverName string = dnsresolvers.name
output dnsResolverId string = dnsresolvers.id
output dnsResolverInboundId string = inboundendpoints.id
output dnsResolverOutboundId string = outboundendpoints.id
