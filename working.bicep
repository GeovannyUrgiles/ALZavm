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
    dnsSettings: {
      servers: []
      enableProxy: true
    }
    sql: {
      allowSqlRedirect: false
    }
  }
}

module firewallPolicy 'br/public:avm/res/network/firewall-policy:0.1.3' = {
  
  name: 'firewallPolicyDeployment'
  params: {
    // Required parameters
    name: 'nfpmax001'
    // Non-required parameters
    allowSqlRedirect: true
    autoLearnPrivateRanges: 'Enabled'
    location: '<location>'
    managedIdentities: {
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    mode: 'Alert'
    ruleCollectionGroups: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'DefaultCollection'
        priority: 1000
      }
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'Dnat'
        }
        rules: []
        name: 'DefaultCollection'
        priority: 1000
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    tier: 'Premium'
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
        name: 'DefaultCollection'
        priority: 1000
      }
      {
        ruleCollectionType: 'FirewallPolicyNatRuleCollection'
        action: {
          type: 'Dnat'
        }
        rules: []
        name: 'DefaultCollection'
        priority: 1000
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'DefaultCollection'
        priority: 1000
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
        name: 'DefaultCollection'
        priority: 1000
      }
    ]
  }
}

resource firewallPolicies_conwus2azfwpol_name_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-01-01' = {
  parent: firewallPolicies_conwus2azfwpol_name_resource
  name: 'DefaultNetworkRuleCollectionGroup'
  location: 'westus2'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: []
        name: 'DefaultCollection'
        priority: 1000
      }
    ]
  }
}

