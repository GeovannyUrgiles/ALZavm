param location string
param vwanHubCAFPrefixes string
param vwanHubAddressSpaces string
param virtualWanId string
param tags object
param preferredRoutingGateway string
param hubRoutingPreference string

// Virtual Network / Virtual WAN Hub 01

resource virtualwanhub 'Microsoft.Network/virtualHubs@2021-05-01' = {
  name: '${vwanHubCAFPrefixes}hub'
  location: location
  tags: tags
  properties: {
    addressPrefix: vwanHubAddressSpaces
    virtualWan: {
      id: virtualWanId
    }
    // preferredRoutingGateway: preferredRoutingGateway
    // hubRoutingPreference: hubRoutingPreference
    sku: 'Standard'

  }
}

output virtualWanHubId string = virtualwanhub.id
output virtualWanHubName string = virtualwanhub.name
