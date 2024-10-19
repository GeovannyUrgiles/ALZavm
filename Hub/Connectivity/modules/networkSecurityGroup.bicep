param location string
param tags object
param securityRules array
param resourceGroupName_Network string
param subnets array
param nsgSuffix string

module modNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnet in subnets: {
    scope: resourceGroup(resourceGroupName_Network)
    name: 'nsgDeployment${subnet}'
    params: {
      name: subnet.name // toLower('${first(subnet)})${nsgSuffix}')
      tags: tags
      location: location
      securityRules: securityRules
    }
  }
]
