{
  name: 'conwus2site'
  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/conwus2site'
  etag: 'W/"b5939041-2c3d-46bb-87ab-e8bf4ed1924a"'
  type: 'Microsoft.Network/vpnSites'
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    provisioningState: 'Succeeded'
    addressSpace: {
      addressPrefixes: [
        '10.100.100.0/24'
        '10.101.101.0/24'
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
        name: 'dc1'
        id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/conwus2site/vpnSiteLinks/dc1'
        etag: 'W/"b5939041-2c3d-46bb-87ab-e8bf4ed1924a"'
        properties: {
          provisioningState: 'Succeeded'
          ipAddress: '2.2.2.2'
          bgpProperties: {
            asn: 65010
            bgpPeeringAddress: '2.2.2.3'
          }
          linkProperties: {
            linkProviderName: 'verizon'
            linkSpeedInMbps: 100
          }
        }
        type: 'Microsoft.Network/vpnSites/vpnSiteLinks'
      }
    ]
  }
}





{
  name: 'conwus2hub'
  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub'
  etag: 'W/"3691989b-d2e8-4303-bf41-e4e126213072"'
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
      id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnGateways/51bcb5200868482b869c692b8269be01-westus2-gw'
    }
    sku: 'Standard'
    routingState: 'Provisioned'
    allowBranchToBranchTraffic: true
    preferredRoutingGateway: 'ExpressRoute'
  }
}




param vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name string = '51bcb5200868482b869c692b8269be01-westus2-gw'
param virtualHubs_conwus2hub_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub'
param vpnSites_conwus2site_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/conwus2site'

resource vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name_resource 'Microsoft.Network/vpnGateways@2024-01-01' = {
  name: vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    connections: [
      {
        name: 'Connection-conwus2site'
        id: vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name_Connection_conwus2site.id
        properties: {
          routingConfiguration: {
            associatedRouteTable: {
              id: '${virtualHubs_conwus2hub_externalid}/hubRouteTables/defaultRouteTable'
            }
            propagatedRouteTables: {
              labels: [
                'default'
              ]
              ids: [
                {
                  id: '${virtualHubs_conwus2hub_externalid}/hubRouteTables/defaultRouteTable'
                }
              ]
            }
          }
          enableInternetSecurity: false
          remoteVpnSite: {
            id: vpnSites_conwus2site_externalid
          }
          vpnLinkConnections: [
            {
              name: 'dc1'
              id: '${vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name_Connection_conwus2site.id}/vpnLinkConnections/dc1'
              properties: {
                vpnSiteLink: {
                  id: '${vpnSites_conwus2site_externalid}/vpnSiteLinks/dc1'
                }
                connectionBandwidth: 10
                ipsecPolicies: []
                vpnConnectionProtocolType: 'IKEv2'
                sharedKey: 'ThievingCat10!'
                enableBgp: true
                enableRateLimiting: false
                useLocalAzureIpAddress: false
                usePolicyBasedTrafficSelectors: false
                routingWeight: 0
                dpdTimeoutSeconds: 0
                vpnLinkConnectionMode: 'Default'
                vpnGatewayCustomBgpAddresses: []
              }
            }
          ]
        }
      }
    ]
    virtualHub: {
      id: virtualHubs_conwus2hub_externalid
    }
    bgpSettings: {
      asn: 65515
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: 'Instance0'
          customBgpIpAddresses: []
        }
        {
          ipconfigurationId: 'Instance1'
          customBgpIpAddresses: []
        }
      ]
    }
    vpnGatewayScaleUnit: 1
    natRules: []
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}

resource vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name_Connection_conwus2site 'Microsoft.Network/vpnGateways/vpnConnections@2024-01-01' = {
  name: '${vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name}/Connection-conwus2site'
  properties: {
    routingConfiguration: {
      associatedRouteTable: {
        id: '${virtualHubs_conwus2hub_externalid}/hubRouteTables/defaultRouteTable'
      }
      propagatedRouteTables: {
        labels: [
          'default'
        ]
        ids: [
          {
            id: '${virtualHubs_conwus2hub_externalid}/hubRouteTables/defaultRouteTable'
          }
        ]
      }
    }
    enableInternetSecurity: false
    remoteVpnSite: {
      id: vpnSites_conwus2site_externalid
    }
    vpnLinkConnections: [
      {
        name: 'dc1'
        id: '${vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name_Connection_conwus2site.id}/vpnLinkConnections/dc1'
        properties: {
          vpnSiteLink: {
            id: '${vpnSites_conwus2site_externalid}/vpnSiteLinks/dc1'
          }
          connectionBandwidth: 10
          ipsecPolicies: []
          vpnConnectionProtocolType: 'IKEv2'
          sharedKey: '308201E806092A864886F70D010703A08201D9308201D5020100318201903082018C0201003074305D310B3009060355040613025553311E301C060355040A13154D6963726F736F667420436F72706F726174696F6E312E302C060355040313254D6963726F736F667420417A7572652052534120544C532049737375696E6720434120303302133300D3AB046DCD7B960411FDC4000000D3AB04300D06092A864886F70D01010730000482010077A4D8FBE519F517D7BE889B05AD1521E4C5234B1586BC22208F7DE537073A820448C3FCF4134000A9D1C52E9EB682C715461E0ED88CFF9C08367E68BA6F613DAF21F6D7E998D4C454A5C5C92968FCE3610828867CE6E714BA3F65F8129A70EDDB8735E2C8C82B4779F8A65EA56E15B28B1CCAECB0FF4DB8D2CB38F4B143F54F1C6ADF7A31671AEAFCEAB70C1BC63FC7C1D1CCE7459608BB8C0BFE470DA7C279903161C2928F6743A51490C3FCECCB544E85065D9EDAAACAB86EE479D243CA9B19B8F1157DAE400674E760A8230D53B058D48D67705ACDFFCD1693DA02674D5CC496987E5F4914F21880801568EDF9D9250F8A685653CBA10175FDD9E5C92F0E303C06092A864886F70D010701301D060960864801650304012A0410772FC0E4F2DD3E23EB4120636029F80B801003CC72706CD3D2648B7C1166A0EE8599'
          enableBgp: true
          enableRateLimiting: false
          useLocalAzureIpAddress: false
          usePolicyBasedTrafficSelectors: false
          routingWeight: 0
          dpdTimeoutSeconds: 0
          vpnLinkConnectionMode: 'Default'
          vpnGatewayCustomBgpAddresses: []
        }
      }
    ]
  }
  dependsOn: [
    vpnGateways_51bcb5200868482b869c692b8269be01_westus2_gw_name_resource
  ]
}
