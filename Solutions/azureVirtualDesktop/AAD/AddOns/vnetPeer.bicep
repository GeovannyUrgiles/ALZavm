param localVnetName string
param remoteVirtualNetworkId string
param friendlyName string 
param remoteAddressSpace string


resource corePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${localVnetName}/${friendlyName}'
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remoteAddressSpace: {
      addressPrefixes: [
        remoteAddressSpace
      ]
    }
    remoteVirtualNetwork: {
      id: remoteVirtualNetworkId
    }
    useRemoteGateways: false
  }
}
