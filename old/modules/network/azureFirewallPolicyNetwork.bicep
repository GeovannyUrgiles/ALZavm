param coreCAFPrefixes string
param location string

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: '${coreCAFPrefixes}fwpol'
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource policyDefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: firewallPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 100
    ruleCollections: [
    ]
  }
}
