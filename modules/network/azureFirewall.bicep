param virtualHubId string
param location string
param coreCAFPrefixes string
param tier string
param numberOfPublicIPs int
param onPremDNSServer string

resource azurefirewalls 'Microsoft.Network/azureFirewalls@2020-11-01' = {
  name: '${coreCAFPrefixes}fw'
  location: location
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: tier
    }
    additionalProperties: {
      'Network.DNS.EnableProxy': 'true'
      'Network.DNS.Servers': onPremDNSServer
    }
    virtualHub: {
      id: virtualHubId
    }
    hubIPAddresses: {
      // privateIPAddress: '${CIDRPrefixes}.64.4'
      publicIPs: {
        count: numberOfPublicIPs
      }
    }
  }
  dependsOn: [
  ]
}

output azureFirewallName string = azurefirewalls.name
output azureFirewallId string = azurefirewalls.id
