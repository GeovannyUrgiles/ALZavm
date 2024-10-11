param coreCAFPrefixes string
param location string

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: '${coreCAFPrefixes}fwpol'
  location: location
  properties: {
    threatIntelMode: 'Alert'
  }
}

resource policyDefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  parent: firewallPolicy
  name: 'DefaultApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'Default Allows'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Allow-msft'
            sourceAddresses: [
              '*'
            ]
            protocols: [
              {
                port: 80
                protocolType: 'Http'
              }
              {
                port: 443
                protocolType: 'Https'
              }
            ]
            targetFqdns: [
              '*.microsoft.com'
            ]
          }
        ]
      }
    ]
  }
}
