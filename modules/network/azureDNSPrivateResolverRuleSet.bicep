param location string
param virtualNetworkId string
param dnsresolvers string
param rulesetEndpoint0 string
param rulesetName string
param vnetLinkName string
param ipAddress0_0 string
param port0_0 int
param ruleName0 string
param domainName0 string
param forwardingRuleState0 string
param rulesDeploymentName string

resource rulesetName_resource 'Microsoft.Network/dnsForwardingRulesets@2020-04-01-preview' = {
  name: rulesetName
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: rulesetEndpoint0
      }
    ]
  }
  dependsOn: [
    dnsresolvers
  ]
}

resource rulesetName_vnetLinkName 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2020-04-01-preview' = {
  parent: rulesetName_resource
  name: '${vnetLinkName}'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
  }
}
