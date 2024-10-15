param coreCAFPrefixes string
param location string

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: '${coreCAFPrefixes}fwpol'
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

output azureFirewallPolicyId string = firewallPolicy.id
output azureFirewallPolicyName string = firewallPolicy.name
