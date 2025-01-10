
param vpnGatewayName string
param connectionBandwidth int
param enableBgp bool
param enableInternetSecurity bool
param enableRateLimiting bool
param ipsecPolicies array

// param dhGroup string
// param ikeEncryption string
// param ikeIntegrity string
// param ipsecEncryption string
// param ipsecIntegrity string
// param pfsGroup string
// param saDataSizeKilobytes string
// param saLifeTimeSeconds string
param remoteVpnSiteResourceId string
param routingConfiguration object
param routingWeight int
param sharedKey string
param trafficSelectorPolicies array
// param localAddressRanges string
// param remoteAddressRanges string
// param trafficSelectors string
// param localPortRanges string
// param protocol string
// param remotePortRanges string
param useLocalAzureIpAddress bool
param usePolicyBasedTrafficSelectors bool
param vpnConnectionProtocolType string
param vpnLinkConnections array

resource vpnGateway 'Microsoft.Network/vpnGateways@2023-04-01' existing = {
  name: vpnGatewayName
}

resource vpnConnections 'Microsoft.Network/vpnGateways/vpnConnections@2023-04-01' = {
  name: 'vpnConnectionDeployment'
  parent: vpnGateway
  properties: {
    connectionBandwidth: connectionBandwidth
    enableBgp: enableBgp
    enableInternetSecurity: enableInternetSecurity
    enableRateLimiting: enableRateLimiting
    ipsecPolicies: ipsecPolicies
    remoteVpnSite: !empty(remoteVpnSiteResourceId)
      ? {
          id: remoteVpnSiteResourceId
        }
      : null
    routingConfiguration: routingConfiguration
    routingWeight: routingWeight
    sharedKey: sharedKey
    trafficSelectorPolicies: trafficSelectorPolicies
    useLocalAzureIpAddress: useLocalAzureIpAddress
    usePolicyBasedTrafficSelectors: usePolicyBasedTrafficSelectors
    vpnConnectionProtocolType: vpnConnectionProtocolType
    vpnLinkConnections: vpnLinkConnections
  }
}
