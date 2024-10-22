param location string
param tags object
param securityRules array
param subnets array
param nsgSuffix string

module modNetworkSecurityGroupPrimary 'br/public:avm/res/network/network-security-group:0.5.0' = [
  // for (subnet, idx) in (subnets): {
     for subnet in range(0, length(subnets)) : {
    name: 'nsgDeployment${subnet.name}'
    params: {
      name: toLower('${subnet.name}${nsgSuffix}')
      tags: tags
      location: location
      securityRules: securityRules
    }
  }
]
