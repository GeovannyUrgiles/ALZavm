param firewallPolicies_conwus2azfwpol_name string = 'conwus2azfwpol'

resource firewallPolicies_conwus2azfwpol_name_resource 'Microsoft.Network/firewallPolicies@2024-01-01' = {
  name: firewallPolicies_conwus2azfwpol_name
  location: 'westus2'
  tags: {
    Environment: 'Non-Prod'
    'hidden-title': 'v1.0.0'
    Role: 'DeploymentValidation'
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Off'
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
    sql: {
      allowSqlRedirect: false
    }
  }
}

resource firewallPolicies_conwus2azfwpol_name_DefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-01-01' = {
  parent: firewallPolicies_conwus2azfwpol_name_resource
  name: 'DefaultApplicationRuleCollectionGroup'
  location: 'westus2'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'AppCollction'
        priority: 5500
      }
    ]
  }
}

resource firewallPolicies_conwus2azfwpol_name_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-01-01' = {
  parent: firewallPolicies_conwus2azfwpol_name_resource
  name: 'DefaultDnatRuleCollectionGroup'
  location: 'westus2'
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'Dnat'
        }
        rules: []
        name: 'DNATRuleCollection'
        priority: 5500
      }
    ]
  }
}

resource firewallPolicies_conwus2azfwpol_name_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-01-01' = {
  parent: firewallPolicies_conwus2azfwpol_name_resource
  name: 'DefaultNetworkRuleCollectionGroup'
  location: 'westus2'
  properties: {
    priority: 5000
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'DefaultNetworkRuleCollection'
        priority: 5555
      }
    ]
  }
}
