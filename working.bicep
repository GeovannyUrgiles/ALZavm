{
  name: 'conwus2hub'
  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub'
  etag: 'W/"65d1c103-f76e-4838-a9b5-9cb75a354029"'
  type: 'Microsoft.Network/virtualHubs'
  location: 'westus2'
  tags: {
    Environment: 'Non-Prod'
    'hidden-title': 'v1.0.0'
    Role: 'DeploymentValidation'
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    provisioningState: 'Succeeded'
    virtualHubRouteTableV2s: []
    addressPrefix: '10.0.0.0/23'
    virtualRouterAsn: 65515
    virtualRouterIps: [
      '10.0.0.69'
      '10.0.0.68'
    ]
    routeTable: {
      routes: []
    }
    securityProviderName: ''
    virtualWan: {
      id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualWans/conwus2vwan'
    }
    vpnGateway: {
      id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnGateways/892f602f0b314d71a1fc50a3221a8e2e-westus2-gw'
    }
    sku: 'Basic'
    routingState: 'Provisioned'
    allowBranchToBranchTraffic: false
    preferredRoutingGateway: 'ExpressRoute'
  }
}



{
  name: '892f602f0b314d71a1fc50a3221a8e2e-westus2-gw'
  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnGateways/892f602f0b314d71a1fc50a3221a8e2e-westus2-gw'
  etag: 'W/"c4cf7202-04ad-444b-9db4-cf01badf4b7a"'
  type: 'Microsoft.Network/vpnGateways'
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    provisioningState: 'Updating'
    connections: [
      {
        name: 'Connection-vpn-site'
        id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnGateways/892f602f0b314d71a1fc50a3221a8e2e-westus2-gw/vpnConnections/Connection-vpn-site'
        etag: 'W/"c4cf7202-04ad-444b-9db4-cf01badf4b7a"'
        type: 'Microsoft.Network/vpnGateways/vpnConnections'
        properties: {
          provisioningState: 'Updating'
          routingConfiguration: {
            associatedRouteTable: {
              id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub/hubRouteTables/defaultRouteTable'
            }
            propagatedRouteTables: {
              labels: [
                'default'
              ]
              ids: [
                {
                  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub/hubRouteTables/defaultRouteTable'
                }
              ]
            }
          }
          enableInternetSecurity: false
          remoteVpnSite: {
            id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/vpn-site'
          }
          vpnLinkConnections: [
            {
              name: 'customer'
              id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnGateways/892f602f0b314d71a1fc50a3221a8e2e-westus2-gw/vpnConnections/Connection-vpn-site/vpnLinkConnections/customer'
              etag: 'W/"c4cf7202-04ad-444b-9db4-cf01badf4b7a"'
              properties: {
                provisioningState: 'Updating'
                vpnSiteLink: {
                  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/vpn-site/vpnSiteLinks/customer'
                }
                connectionBandwidth: 10
                ipsecPolicies: [
                  {
                    saLifeTimeSeconds: 27000
                    saDataSizeKilobytes: 0
                    ipsecEncryption: 'GCMAES256'
                    ipsecIntegrity: 'GCMAES256'
                    ikeEncryption: 'GCMAES256'
                    ikeIntegrity: 'SHA384'
                    dhGroup: 'DHGroup24'
                    pfsGroup: 'PFS14'
                  }
                ]
                vpnConnectionProtocolType: 'IKEv2'
                sharedKey: 'sdfsdfsdf'
                ingressBytesTransferred: 0
                egressBytesTransferred: 0
                packetCaptureDiagnosticState: 'None'
                enableBgp: true
                enableRateLimiting: false
                useLocalAzureIpAddress: false
                usePolicyBasedTrafficSelectors: false
                routingWeight: 0
                dpdTimeoutSeconds: 0
                vpnLinkConnectionMode: 'Default'
                vpnGatewayCustomBgpAddresses: []
              }
              type: 'Microsoft.Network/vpnGateways/vpnConnections/vpnLinkConnections'
            }
          ]
          ingressBytesTransferred: 0
          egressBytesTransferred: 0
        }
      }
    ]
    virtualHub: {
      id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub'
    }
    bgpSettings: {
      asn: 65515
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: 'Instance0'
          defaultBgpIpAddresses: [
            '10.0.0.13'
          ]
          customBgpIpAddresses: []
          tunnelIpAddresses: [
            '172.179.96.105'
            '10.0.0.4'
          ]
        }
        {
          ipconfigurationId: 'Instance1'
          defaultBgpIpAddresses: [
            '10.0.0.12'
          ]
          customBgpIpAddresses: []
          tunnelIpAddresses: [
            '172.179.99.207'
            '10.0.0.5'
          ]
        }
      ]
    }
    vpnGatewayScaleUnit: 1
    packetCaptureDiagnosticState: 'None'
    ipConfigurations: [
      {
        id: 'Instance0'
        publicIpAddress: '172.179.96.105'
        privateIpAddress: '10.0.0.4'
      }
      {
        id: 'Instance1'
        publicIpAddress: '172.179.99.207'
        privateIpAddress: '10.0.0.5'
      }
    ]
    natRules: []
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}






{
  name: 'vpn-site'
  // id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/vpn-site'
  etag: 'W/"438a9d8f-0b78-440c-bb25-4525d633be79"'
  type: 'Microsoft.Network/vpnSites'
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    provisioningState: 'Succeeded'
    addressSpace: {
      addressPrefixes: [
        '10.200.0.0/24'
        '10.200.1.0/24'
      ]
    }
    deviceProperties: {
      deviceVendor: 'Cisco'
      linkSpeedInMbps: 0
    }
    virtualWan: {
      id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualWans/conwus2vwan'
    }
    isSecuritySite: false
    o365Policy: {
      breakOutCategories: {
        optimize: false
        allow: false
        default: false
      }
    }
    vpnSiteLinks: [
      {
        name: 'customer'
        id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/vpn-site/vpnSiteLinks/customer'
        etag: 'W/"438a9d8f-0b78-440c-bb25-4525d633be79"'
        properties: {
          provisioningState: 'Succeeded'
          ipAddress: '1.1.1.1'
          bgpProperties: {
            asn: 65010
            bgpPeeringAddress: '2.2.2.2'
          }
          linkProperties: {
            linkProviderName: 'verizon'
            linkSpeedInMbps: 1000
          }
        }
        type: 'Microsoft.Network/vpnSites/vpnSiteLinks'
      }
    ]
  }
}




