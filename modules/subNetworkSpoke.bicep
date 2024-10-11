targetScope = 'subscription'

param enableSpokeSubnets bool

param spokeSubscriptionIds string
param spokeAddressSpaces string
param spokeCIDRPrefixes string
param spokeCAFPrefixes string

param vwanHubCAFPrefixes array
param vwanHubSubscriptionIds array

param coreSubscriptionIds string

param dnsFirewallProxy array
param dnsPrivateResolver array
param enableFirewall bool

param privateDNSZoneNameAutomation string
param privateDNSZoneNameKeyVault string
param privateDNSZoneNameStorageBlob string
param privateDNSZoneNameStorageFile string
param privateDNSZoneNameStorageTable string
param privateDNSZoneNameStorageQueue string

param nsgRules array

param location string
param tenantId string
param servicePrincipalAppId string
@secure()
param secret string

// Override from main.bicep
var enableRecoveryServiceVault = false

param tags object

// Subnets / Dev > Test > Stage > UAT > Prod Spokes
// Basic Array - retain mandatory .254 Private Endpoint subnet

param subnetsSpoke array = [
  // Azure PrivateEndpoint Subnet
  {
    name: 'AzurePrivateEndpointSubnet'
    subnetPrefix: '${spokeCIDRPrefixes}.254.0/23'
  }
]

// Preconfigured Array - retain mandatory .254 Private Endpoint subnet, edit to need

param subnetsSpokePreconfigured array = [
  // Azure AKS 1 Subnet
  {
    name: 'AzureAKS1Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.200.0/22'
  }
  // Azure AKS 2 Subnet
  {
    name: 'AzureAKS2Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.208.0/22'
  }
  // Azure Databricks 1 Private Subnet
  {
    name: 'AzureDatabricks1PrivateSubnet'
    subnetPrefix: '${spokeCIDRPrefixes}.216.0/22'
  }
  // Azure Databricks 1 Public Subnet
  {
    name: 'AzureDatabricks1PublicSubnet'
    subnetPrefix: '${spokeCIDRPrefixes}.224.0/22'
  }
  // Azure Databricks 2 Private Subnet
  {
    name: 'AzureDatabricks2PrivateSubnet'
    subnetPrefix: '${spokeCIDRPrefixes}.232.0/22'
  }
  // Azure Databricks 2 Public Subnet
  {
    name: 'AzureDatabricks2PublicSubnet'
    subnetPrefix: '${spokeCIDRPrefixes}.240.0/22'
  }
  // Virtual Network Integration / 01
  {
    name: 'AzureVirtualNetworkIntegration1Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.0/27'
  }
  // Virtual Network Integration / 02
  {
    name: 'AzureVirtualNetworkIntegration2Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.32/27'
  }
  // Virtual Network Integration / 03
  {
    name: 'AzureVirtualNetworkIntegration3Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.64/27'
  }
  // Virtual Network Integration / 04
  {
    name: 'AzureVirtualNetworkIntegration4Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.96/27'
  }
  // Virtual Network Integration / 05
  {
    name: 'AzureVirtualNetworkIntegration5Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.128/27'
  }
  // Virtual Network Integration / 06
  {
    name: 'AzureVirtualNetworkIntegration6Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.160/27'
  }
  // Virtual Network Integration / 07
  {
    name: 'AzureVirtualNetworkIntegration7Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.192/27'
  }
  // Virtual Network Integration / 08
  {
    name: 'AzureVirtualNetworkIntegration8Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.245.224/27'
  }
  // Azure ISE Subnets (4 required)
  {
    name: 'AzureISE1Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.250.0/24'
  }
  {
    name: 'AzureISE2Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.251.0/24'
  }
  {
    name: 'AzureISE3Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.252.0/24'
  }
  {
    name: 'AzureISE4Subnet'
    subnetPrefix: '${spokeCIDRPrefixes}.253.0/24'
  }
  // Azure PrivateEndpoint Subnet
  {
    name: 'AzurePrivateEndpointSubnet'
    subnetPrefix: '${spokeCIDRPrefixes}.254.0/23'
  }
]

// Resource Group

resource resourceGroupNetworkSpoke 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${spokeCAFPrefixes}networkrg'
  location: location
  tags: tags
  dependsOn: [
  ]
}

// Virtual Network Spokes

module virtualNetworkSpoke 'network/virtualNetworkSpoke.bicep' = {
  scope: resourceGroupNetworkSpoke
  name: '${spokeCAFPrefixes}vnet'
  params: {
    servicePrincipalAppId: servicePrincipalAppId
    spokeSubscriptionIds: spokeSubscriptionIds
    nsgRules: nsgRules
    spokeAddressSpaces: spokeAddressSpaces
    spokeCAFPrefixes: spokeCAFPrefixes
    dnsServers: ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver) 
    location: location
    subnets: ((enableSpokeSubnets == true) ? subnetsSpokePreconfigured : subnetsSpoke) 
    tags: tags
  }
  dependsOn: [
  ]
}

// Build Dynamic Spoke Id Outputs

module dynamicSpokeIds 'network/dynamicSubnets.bicep' = {
  scope: resourceGroupNetworkSpoke
  name: 'dynamicSubnets.bicep.dynamicSpokeIds'
  params: {
    secret: secret
    tenantId: tenantId
    subscriptionId: spokeSubscriptionIds
    servicePrincipalAppId: servicePrincipalAppId
    location: location
    virtualNetworkName: virtualNetworkSpoke.outputs.virtualNetworkNameSpoke
  }
  dependsOn: [
    virtualNetworkSpoke
  ]
}

// Virtual Network Connections initiated from VWAN

module coreHubToSpoke 'network/virtualWanHubPeering.bicep' = {
  scope: resourceGroup(vwanHubSubscriptionIds[0], '${vwanHubCAFPrefixes[0]}networkrg')
  name: '${vwanHubCAFPrefixes[0]}hub-to-${virtualNetworkSpoke.name}'
  params: {
    coreSubscriptionIds: coreSubscriptionIds
    virtualNetworkSpokeName: virtualNetworkSpoke.outputs.virtualNetworkNameSpoke
    virtualWanHubName: '${vwanHubCAFPrefixes[0]}hub'
    virtualNetworkSpokeId: virtualNetworkSpoke.outputs.virtualNetworkIdSpoke
    location: location
  }
  dependsOn: [
    virtualNetworkSpoke
  ]
}


// Deploy Common Subscription-wide Resources

module sharedResources 'subCommonResources.bicep' = {
  scope: subscription(spokeSubscriptionIds)
  name: 'subNetworkSpoke.bicep.sharedResources'
  params: {
    pepSubnetId: dynamicSpokeIds.outputs.azurePrivateEndpointSubnetId
    privateDNSZoneNameAutomation: privateDNSZoneNameAutomation
    privateDNSZoneNameKeyVault: privateDNSZoneNameKeyVault
    privateDNSZoneNameStorageBlob: privateDNSZoneNameStorageBlob
    privateDNSZoneNameStorageFile: privateDNSZoneNameStorageFile
    privateDNSZoneNameStorageTable: privateDNSZoneNameStorageTable
    privateDNSZoneNameStorageQueue: privateDNSZoneNameStorageQueue
    enableRecoveryServiceVault: enableRecoveryServiceVault
    spokeCAFPrefixes: spokeCAFPrefixes
    spokeCIDRPrefixes: spokeCIDRPrefixes
    location: location
    tenantId: tenantId
    tags: tags
  }
  dependsOn: [
    virtualNetworkSpoke
    dynamicSpokeIds
  ]
}

output virtualNetworkSpokeName string = virtualNetworkSpoke.outputs.virtualNetworkNameSpoke
output virtualNetworkSpokeId string = virtualNetworkSpoke.outputs.virtualNetworkIdSpoke
