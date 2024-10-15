param virtualWanHubName string
param virtualWanHubId string
param location string
param bgpSettings int
param vpnGatewayScaleUnit int

resource virtualwangateways2s 'Microsoft.Network/vpnGateways@2021-05-01'= /*if (subscription().subscriptionId == subname)*/ {
  name: '${virtualWanHubName}s2sgw'
  location: location
  properties: {
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    isRoutingPreferenceInternet: false
    bgpSettings: {
      asn: bgpSettings
    }
    virtualHub: {
      id: virtualWanHubId
    }
  }
}

output virtualWanGWs2sId string = virtualwangateways2s.id
output virtualWanGWs2sName string = virtualwangateways2s.name
