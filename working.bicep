{
  name: 'conwus2hub'
  id: '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub'
  etag: 'W/"f10a83a7-74f8-42e6-8882-c3011be047a5"'
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
    sku: 'Standard'
    routingState: 'Provisioned'
    allowBranchToBranchTraffic: true
    preferredRoutingGateway: 'ExpressRoute'
  }
}




param vpnGateways_conwus2vpngw_name string = 'conwus2vpngw'
param virtualHubs_conwus2hub_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualHubs/conwus2hub'
param vpnSites_conwus2vpnsite_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/vpnSites/conwus2vpnsite'

resource vpnGateways_conwus2vpngw_name_resource 'Microsoft.Network/vpnGateways@2024-01-01' = {
  name: vpnGateways_conwus2vpngw_name
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    connections: [
      {
        name: 'Connection-conwus2vpnsite'
        id: vpnGateways_conwus2vpngw_name_Connection_conwus2vpnsite.id
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
            id: vpnSites_conwus2vpnsite_externalid
          }
          vpnLinkConnections: [
            {
              name: 'Country1'
              id: '${vpnGateways_conwus2vpngw_name_Connection_conwus2vpnsite.id}/vpnLinkConnections/Country1'
              properties: {
                vpnSiteLink: {
                  id: '${vpnSites_conwus2vpnsite_externalid}/vpnSiteLinks/Country1'
                }
                connectionBandwidth: 10
                ipsecPolicies: [
                  {
                    saLifeTimeSeconds: 27000
                    saDataSizeKilobytes: 0
                    ipsecEncryption: 'GCMAES256'
                    ipsecIntegrity: 'GCMAES256'
                    ikeEncryption: 'AES256'
                    ikeIntegrity: 'SHA256'
                    dhGroup: 'ECP256'
                    pfsGroup: 'PFS14'
                  }
                ]
                vpnConnectionProtocolType: 'IKEv2'
                sharedKey: 'ThinevingCat10!'
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
            {
              name: 'Acquisition2'
              id: '${vpnGateways_conwus2vpngw_name_Connection_conwus2vpnsite.id}/vpnLinkConnections/Acquisition2'
              properties: {
                vpnSiteLink: {
                  id: '${vpnSites_conwus2vpnsite_externalid}/vpnSiteLinks/Acquisition2'
                }
                connectionBandwidth: 10
                ipsecPolicies: [
                  {
                    saLifeTimeSeconds: 27000
                    saDataSizeKilobytes: 0
                    ipsecEncryption: 'GCMAES256'
                    ipsecIntegrity: 'GCMAES256'
                    ikeEncryption: 'AES256'
                    ikeIntegrity: 'SHA256'
                    dhGroup: 'ECP256'
                    pfsGroup: 'PFS14'
                  }
                ]
                vpnConnectionProtocolType: 'IKEv2'
                sharedKey: 'ThinevingCat10!'
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
    vpnGatewayScaleUnit: 2
    natRules: []
    enableBgpRouteTranslationForNat: false
    isRoutingPreferenceInternet: false
  }
}

resource vpnGateways_conwus2vpngw_name_Connection_conwus2vpnsite 'Microsoft.Network/vpnGateways/vpnConnections@2024-01-01' = {
  name: '${vpnGateways_conwus2vpngw_name}/Connection-conwus2vpnsite'
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
      id: vpnSites_conwus2vpnsite_externalid
    }
    vpnLinkConnections: [
      {
        name: 'Country1'
        id: '${vpnGateways_conwus2vpngw_name_Connection_conwus2vpnsite.id}/vpnLinkConnections/Country1'
        properties: {
          vpnSiteLink: {
            id: '${vpnSites_conwus2vpnsite_externalid}/vpnSiteLinks/Country1'
          }
          connectionBandwidth: 10
          ipsecPolicies: [
            {
              saLifeTimeSeconds: 27000
              saDataSizeKilobytes: 0
              ipsecEncryption: 'GCMAES256'
              ipsecIntegrity: 'GCMAES256'
              ikeEncryption: 'AES256'
              ikeIntegrity: 'SHA256'
              dhGroup: 'ECP256'
              pfsGroup: 'PFS14'
            }
          ]
          vpnConnectionProtocolType: 'IKEv2'
          sharedKey: '308201E806092A864886F70D010703A08201D9308201D5020100318201903082018C0201003074305D310B3009060355040613025553311E301C060355040A13154D6963726F736F667420436F72706F726174696F6E312E302C060355040313254D6963726F736F667420417A7572652052534120544C532049737375696E6720434120303302133300D3AB046DCD7B960411FDC4000000D3AB04300D06092A864886F70D0101073000048201008D6F36E195365DFB5BCCB690FF5B1D80B002BBC15B1E0FCDA78941D9E295FE8B7960685CBE7B779DFCEADF328442930531E833C93B725BD909763D3ED81768CDAD1881E21EB40D3498BED29713DB4DAFD75B4DFC37527B750338BA2B1E321D9D9CE81AD58BFAE2CDCC174926AAAB70E7B3A39FF0FC05EF45A8AA933BF1B6BC442E8E085312CB5478F6A6AA7BA1FAE6F416E59F1B61798F56D26A1BCC7024910B29FDB84E53688915179FD50FABB3F91640829B4C655D08B6AE8203A08C1B4BC72CF6BB2FB03FA496AE718048984D1AEC82A14A98B7D998120C2A2A0ACE523EFD0BF9C8A9F1F1395E0216FD68DFA5541E1E9E675D84167976D3F7B7F2F7F6A86A303C06092A864886F70D010701301D060960864801650304012A0410A4132C51106F1AD9D719E2DEFBD1C2C380102FBAD823911E05DB3B5381A365DF558F'
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
      {
        name: 'Acquisition2'
        id: '${vpnGateways_conwus2vpngw_name_Connection_conwus2vpnsite.id}/vpnLinkConnections/Acquisition2'
        properties: {
          vpnSiteLink: {
            id: '${vpnSites_conwus2vpnsite_externalid}/vpnSiteLinks/Acquisition2'
          }
          connectionBandwidth: 10
          ipsecPolicies: [
            {
              saLifeTimeSeconds: 27000
              saDataSizeKilobytes: 0
              ipsecEncryption: 'GCMAES256'
              ipsecIntegrity: 'GCMAES256'
              ikeEncryption: 'AES256'
              ikeIntegrity: 'SHA256'
              dhGroup: 'ECP256'
              pfsGroup: 'PFS14'
            }
          ]
          vpnConnectionProtocolType: 'IKEv2'
          sharedKey: '308201E806092A864886F70D010703A08201D9308201D5020100318201903082018C0201003074305D310B3009060355040613025553311E301C060355040A13154D6963726F736F667420436F72706F726174696F6E312E302C060355040313254D6963726F736F667420417A7572652052534120544C532049737375696E6720434120303302133300D3AB046DCD7B960411FDC4000000D3AB04300D06092A864886F70D010107300004820100AA845A082B15443791DFC8AA91E2AEDCC16C22D4772F53B4C1A90BD2DA7DA370A373A5C9EBD96ECE15367E9EBFDF71104D11A3B9F7DF8C603830C01D2CE3C2042E259C11E29386069D07D7EE04523D333BE19E206E603C3B0E7B02B359AF7E461419A8A42A4D9F2F3ED7A7876FEF085D9EFA409384AA1838C06B38CF242C41AC5061631043569F908EB43AE532E4F9BAED1DD477B6934491149A154A4FB4BED550468361C226BC6809441C63E08A8F6A4483EFFFECE2791690F2AAAB399BEF6AF99A29B2BF82205E6FF7C31EA41F190956D34DAC80521052A4C8EAA1546B676F79FE2A24A23E1A088BBA93F75ED6BD4F13606F191B8CB3F6641971B5AAF20824303C06092A864886F70D010701301D060960864801650304012A041020A4CDC167762F8412927168FBDFA21180106C789202598A75D2B1E61F54F9EDD47E'
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
    vpnGateways_conwus2vpngw_name_resource
  ]
}

