param location string
param tags object
param securityRules array
param resourceGroupName_Network string
param subnets array
param nsgSuffix string

module modNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnetName in subnets: {
    scope: resourceGroup(resourceGroupName_Network)
    name: 'nsgDeployment${subnetName}'
    params: {
      name: toLower('${subnetName}${nsgSuffix}')
      tags: tags
      location: location
      securityRules: securityRules
    }
  }
]
