param dnsServers array
param nsgRules array
param subnets array
// param virtualWanHubId string
param spokeAddressSpaces string
param spokeCAFPrefixes string
param location string
param servicePrincipalAppId string
param spokeSubscriptionIds string
// param spokeCIDRPrefixes string
// param azureDNSPrivateResolver string
// param azureFirewallDNSProxy string
// param dnsFirewallProxy array
// param dnsPrivateResolver array
param tags object

targetScope = 'resourceGroup'

resource networksecuritygroups 'Microsoft.Network/networkSecurityGroups@2019-02-01' = [for subnet in subnets: {
  name: '${toLower(subnet.name)}nsg'
  location: location
  tags: tags
  properties: {
    securityRules: nsgRules
  }
}]

//  

resource virtualnetworksspoke 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${spokeCAFPrefixes}vnet'
  location: location
  tags: tags
  properties: {
    subnets: [for subnet in subnets: {
      name: subnet.name
      // if subnet.name is AzureDatabricksPrivateSubnet then delegate
      properties: subnet.name == 'AzureDatabricks1PrivateSubnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Databricks/workspaces'
            }
          }
        ]
        // if subnet.name is AzureDatabricksPublicSubnet then delegate
      } : subnet.name == 'AzureDatabricks1PublicSubnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Databricks/workspaces'
            }
          }
        ]
        // if subnet.name is AzureDatabricksPrivateSubnet then delegate
      } : subnet.name == 'AzureDatabricks2PrivateSubnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Databricks/workspaces'
            }
          }
        ]
        // if subnet.name is AzureDatabricksPublicSubnet then delegate
      } : subnet.name == 'AzureDatabricks2PublicSubnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Databricks/workspaces'
            }
          }
        ]
        // if subnet.name is AzureVNISubnet then delegate
      } : subnet.name == 'AzureVirtualNetworkIntegration1Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // if subnet.name is AzureVNISubnet then delegate
      } : subnet.name == 'AzureVirtualNetworkIntegration2Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // else 
      } : subnet.name == 'AzureVirtualNetworkIntegration3Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // if subnet.name is AzureVNISubnet then delegate
      } : subnet.name == 'AzureVirtualNetworkIntegration4Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // else 
      } : subnet.name == 'AzureVirtualNetworkIntegration5Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // if subnet.name is AzureVNISubnet then delegate
      } : subnet.name == 'AzureVirtualNetworkIntegration6Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // else 
      } : subnet.name == 'AzureVirtualNetworkIntegration7Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // if subnet.name is AzureVNISubnet then delegate
      } : subnet.name == 'AzureVirtualNetworkIntegration8Subnet' ? {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
        delegations: [
          {
            name: 'delegation'
            properties: {
              serviceName: 'Microsoft.Web/serverFarms'
            }
          }
        ]
        // else 
      } : {
        networkSecurityGroup: {
          id: resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', '${subnet.name}nsg')
        }
        addressPrefix: subnet.subnetPrefix
      }
    }]
    addressSpace: {
      addressPrefixes: [
        spokeAddressSpaces
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
  }
  dependsOn: [
    networksecuritygroups
  ]
}

output virtualNetworkNameSpoke string = virtualnetworksspoke.name
output virtualNetworkConnectionSpoke string = virtualnetworksspoke.name
output virtualNetworkIdSpoke string = virtualnetworksspoke.id
