resource modConnections 'Microsoft.Network/connections@2023-11-01' = {
  name: connectionName
  location: location[0]
  tags: {
    tags
  }
  properties: {
    authorizationKey: authorizationKey
    connectionMode: connectionMode
    connectionProtocol: connectionProtocol
    connectionType: connectionType
    dpdTimeoutSeconds: dpdTimeoutSeconds
    egressNatRules: [
      {
        id: egressNatRules
      }
    ]
    enableBgp: enableBgp //bool
    enablePrivateLinkFastPath: enablePrivateLinkFastPath //bool
    expressRouteGatewayBypass: expressRouteGatewayBypass //bool
    gatewayCustomBgpIpAddresses: [
      {
        customBgpIpAddress: customBgpIpAddress
        ipConfigurationId: ipConfigurationId
      }
    ]
    ingressNatRules: [
      {
        id: ingressNatRules
      }
    ]
    ipsecPolicies: [
      {
        dhGroup: dhGroup
        ikeEncryption: ikeEncryption
        ikeIntegrity: ikeIntegrity
        ipsecEncryption: ipsecEncryption
        ipsecIntegrity: ipsecIntegrity
        pfsGroup: pfsGroup
        saDataSizeKilobytes: saDataSizeKilobytes
        saLifeTimeSeconds: saLifeTimeSeconds
      }
    ]
    localNetworkGateway2: {
      id: id
      location: location[0]
      properties: {
        bgpSettings: {
          asn: asn
          bgpPeeringAddress: bgpPeeringAddress
          bgpPeeringAddresses: [
            {
              customBgpIpAddresses: [
                customBgpIpAddresses
              ]
              ipconfigurationId: ipconfigurationId
            }
          ]
          peerWeight: peerWeight
        }
        fqdn: fqdn
        gatewayIpAddress: gatewayIpAddress
        localNetworkAddressSpace: {
          addressPrefixes: [
            addressPrefixes
          ]
        }
      }
      tags: {}
    }
    peer: {
      id: id
    }
    routingWeight: routingWeight
    sharedKey: sharedKey
    trafficSelectorPolicies: [
      {
        localAddressRanges: [
          'string'
        ]
        remoteAddressRanges: [
          'string'
        ]
      }
    ]
    useLocalAzureIpAddress: bool
    usePolicyBasedTrafficSelectors: bool
    virtualNetworkGateway1: {
      extendedLocation: {
        name: 'string'
        type: 'EdgeZone'
      }
      id: 'string'
      location: 'string'
      properties: {
        activeActive: bool
        adminState: 'string'
        allowRemoteVnetTraffic: bool
        allowVirtualWanTraffic: bool
        autoScaleConfiguration: {
          bounds: {
            max: int
            min: int
          }
        }
        bgpSettings: {
          asn: int
          bgpPeeringAddress: 'string'
          bgpPeeringAddresses: [
            {
              customBgpIpAddresses: [
                'string'
              ]
              ipconfigurationId: 'string'
            }
          ]
          peerWeight: int
        }
        customRoutes: {
          addressPrefixes: [
            'string'
          ]
        }
        disableIPSecReplayProtection: bool
        enableBgp: bool
        enableBgpRouteTranslationForNat: bool
        enableDnsForwarding: bool
        enablePrivateIpAddress: bool
        gatewayDefaultSite: {
          id: 'string'
        }
        gatewayType: 'string'
        ipConfigurations: [
          {
            id: 'string'
            name: 'string'
            properties: {
              privateIPAllocationMethod: 'string'
              publicIPAddress: {
                id: 'string'
              }
              subnet: {
                id: 'string'
              }
            }
          }
        ]
        natRules: [
          {
            id: 'string'
            name: 'string'
            properties: {
              externalMappings: [
                {
                  addressSpace: 'string'
                  portRange: 'string'
                }
              ]
              internalMappings: [
                {
                  addressSpace: 'string'
                  portRange: 'string'
                }
              ]
              ipConfigurationId: 'string'
              mode: 'string'
              type: 'string'
            }
          }
        ]
        sku: {
          name: 'string'
          tier: 'string'
        }
        virtualNetworkGatewayPolicyGroups: [
          {
            id: 'string'
            name: 'string'
            properties: {
              isDefault: bool
              policyMembers: [
                {
                  attributeType: 'string'
                  attributeValue: 'string'
                  name: 'string'
                }
              ]
              priority: int
            }
          }
        ]
        vNetExtendedLocationResourceId: 'string'
        vpnClientConfiguration: {
          aadAudience: 'string'
          aadIssuer: 'string'
          aadTenant: 'string'
          radiusServerAddress: 'string'
          radiusServers: [
            {
              radiusServerAddress: 'string'
              radiusServerScore: int
              radiusServerSecret: 'string'
            }
          ]
          radiusServerSecret: 'string'
          vngClientConnectionConfigurations: [
            {
              id: 'string'
              name: 'string'
              properties: {
                virtualNetworkGatewayPolicyGroups: [
                  {
                    id: 'string'
                  }
                ]
                vpnClientAddressPool: {
                  addressPrefixes: [
                    'string'
                  ]
                }
              }
            }
          ]
          vpnAuthenticationTypes: [
            'string'
          ]
          vpnClientAddressPool: {
            addressPrefixes: [
              'string'
            ]
          }
          vpnClientIpsecPolicies: [
            {
              dhGroup: 'string'
              ikeEncryption: 'string'
              ikeIntegrity: 'string'
              ipsecEncryption: 'string'
              ipsecIntegrity: 'string'
              pfsGroup: 'string'
              saDataSizeKilobytes: int
              saLifeTimeSeconds: int
            }
          ]
          vpnClientProtocols: [
            'string'
          ]
          vpnClientRevokedCertificates: [
            {
              id: 'string'
              name: 'string'
              properties: {
                thumbprint: 'string'
              }
            }
          ]
          vpnClientRootCertificates: [
            {
              id: 'string'
              name: 'string'
              properties: {
                publicCertData: 'string'
              }
            }
          ]
        }
        vpnGatewayGeneration: 'string'
        vpnType: 'string'
      }
      tags: {}
    }
    virtualNetworkGateway2: {
      extendedLocation: {
        name: 'string'
        type: 'EdgeZone'
      }
      id: 'string'
      location: 'string'
      properties: {
        activeActive: bool
        adminState: 'string'
        allowRemoteVnetTraffic: bool
        allowVirtualWanTraffic: bool
        autoScaleConfiguration: {
          bounds: {
            max: int
            min: int
          }
        }
        bgpSettings: {
          asn: int
          bgpPeeringAddress: 'string'
          bgpPeeringAddresses: [
            {
              customBgpIpAddresses: [
                'string'
              ]
              ipconfigurationId: 'string'
            }
          ]
          peerWeight: int
        }
        customRoutes: {
          addressPrefixes: [
            'string'
          ]
        }
        disableIPSecReplayProtection: bool
        enableBgp: bool
        enableBgpRouteTranslationForNat: bool
        enableDnsForwarding: bool
        enablePrivateIpAddress: bool
        gatewayDefaultSite: {
          id: 'string'
        }
        gatewayType: 'string'
        ipConfigurations: [
          {
            id: 'string'
            name: 'string'
            properties: {
              privateIPAllocationMethod: 'string'
              publicIPAddress: {
                id: 'string'
              }
              subnet: {
                id: 'string'
              }
            }
          }
        ]
        natRules: [
          {
            id: 'string'
            name: 'string'
            properties: {
              externalMappings: [
                {
                  addressSpace: 'string'
                  portRange: 'string'
                }
              ]
              internalMappings: [
                {
                  addressSpace: 'string'
                  portRange: 'string'
                }
              ]
              ipConfigurationId: 'string'
              mode: 'string'
              type: 'string'
            }
          }
        ]
        sku: {
          name: 'string'
          tier: 'string'
        }
        virtualNetworkGatewayPolicyGroups: [
          {
            id: 'string'
            name: 'string'
            properties: {
              isDefault: bool
              policyMembers: [
                {
                  attributeType: 'string'
                  attributeValue: 'string'
                  name: 'string'
                }
              ]
              priority: int
            }
          }
        ]
        vNetExtendedLocationResourceId: 'string'
        vpnClientConfiguration: {
          aadAudience: 'string'
          aadIssuer: 'string'
          aadTenant: 'string'
          radiusServerAddress: 'string'
          radiusServers: [
            {
              radiusServerAddress: 'string'
              radiusServerScore: int
              radiusServerSecret: 'string'
            }
          ]
          radiusServerSecret: 'string'
          vngClientConnectionConfigurations: [
            {
              id: 'string'
              name: 'string'
              properties: {
                virtualNetworkGatewayPolicyGroups: [
                  {
                    id: 'string'
                  }
                ]
                vpnClientAddressPool: {
                  addressPrefixes: [
                    'string'
                  ]
                }
              }
            }
          ]
          vpnAuthenticationTypes: [
            'string'
          ]
          vpnClientAddressPool: {
            addressPrefixes: [
              'string'
            ]
          }
          vpnClientIpsecPolicies: [
            {
              dhGroup: 'string'
              ikeEncryption: 'string'
              ikeIntegrity: 'string'
              ipsecEncryption: 'string'
              ipsecIntegrity: 'string'
              pfsGroup: 'string'
              saDataSizeKilobytes: int
              saLifeTimeSeconds: int
            }
          ]
          vpnClientProtocols: [
            'string'
          ]
          vpnClientRevokedCertificates: [
            {
              id: 'string'
              name: 'string'
              properties: {
                thumbprint: 'string'
              }
            }
          ]
          vpnClientRootCertificates: [
            {
              id: 'string'
              name: 'string'
              properties: {
                publicCertData: 'string'
              }
            }
          ]
        }
        vpnGatewayGeneration: 'string'
        vpnType: 'string'
      }
      tags: {}
    }
  }
}
