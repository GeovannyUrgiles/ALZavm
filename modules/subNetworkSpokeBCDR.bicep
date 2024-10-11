targetScope = 'subscription'

param enableSpokeSubnets bool
param spokeSubscriptionIdsBCDR string
param spokeAddressSpacesBCDR string
param spokeCIDRPrefixesBCDR string
param spokeCAFPrefixesBCDR string

param vwanHubCAFPrefixes array
param vwanHubSubscriptionIds array

param coreSubscriptionIds string

param privateDNSZoneNameAutomation string
param privateDNSZoneNameKeyVault string
param privateDNSZoneNameStorageBlob string
param privateDNSZoneNameStorageFile string
param privateDNSZoneNameStorageTable string
param privateDNSZoneNameStorageQueue string

param enableFirewall bool
param dnsFirewallProxy array
param dnsPrivateResolver array
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
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.254.0/23'
  }
]

// Preconfigured Array - retain mandatory .254 Private Endpoint subnet, edit to fit need

param subnetsSpokePreconfigured array = [
  // Azure AKS 1 Subnet
  {
    name: 'AzureAKS1Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.200.0/22'
  }
  // Azure AKS 2 Subnet
  {
    name: 'AzureAKS2Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.208.0/22'
  }
  // Azure Databricks 1 Private Subnet
  {
    name: 'AzureDatabricks1PrivateSubnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.216.0/22'
  }
  // Azure Databricks 1 Public Subnet
  {
    name: 'AzureDatabricks1PublicSubnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.224.0/22'
  }
  // Azure Databricks 2 Private Subnet
  {
    name: 'AzureDatabricks2PrivateSubnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.232.0/22'
  }
  // Azure Databricks 2 Public Subnet
  {
    name: 'AzureDatabricks2PublicSubnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.240.0/22'
  }
  // Virtual Network Integration / 01
  {
    name: 'AzureVirtualNetworkIntegration1Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.0/27'
  }
  // Virtual Network Integration / 02
  {
    name: 'AzureVirtualNetworkIntegration2Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.32/27'
  }
  // Virtual Network Integration / 03
  {
    name: 'AzureVirtualNetworkIntegration3Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.64/27'
  }
  // Virtual Network Integration / 04
  {
    name: 'AzureVirtualNetworkIntegration4Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.96/27'
  }
  // Virtual Network Integration / 05
  {
    name: 'AzureVirtualNetworkIntegration5Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.128/27'
  }
  // Virtual Network Integration / 06
  {
    name: 'AzureVirtualNetworkIntegration6Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.160/27'
  }
  // Virtual Network Integration / 07
  {
    name: 'AzureVirtualNetworkIntegration7Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.192/27'
  }
  // Virtual Network Integration / 08
  {
    name: 'AzureVirtualNetworkIntegration8Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.245.224/27'
  }
  // Azure ISE Subnets (4 required)
  {
    name: 'AzureISE1Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.250.0/24'
  }
  {
    name: 'AzureISE2Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.251.0/24'
  }
  {
    name: 'AzureISE3Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.252.0/24'
  }
  {
    name: 'AzureISE4Subnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.253.0/24'
  }
  // Azure PrivateEndpoint Subnet
  {
    name: 'AzurePrivateEndpointSubnet'
    subnetPrefix: '${spokeCIDRPrefixesBCDR}.254.0/23'
  }
]

// Resource Group

resource resourceGroupNetworkSpokeBCDR 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${spokeCAFPrefixesBCDR}networkrg'
  location: location
  tags: tags
  dependsOn: [
  ]
}

// Virtual Network Spoke

module virtualNetworkSpokeBCDR 'network/virtualNetworkSpoke.bicep' = {
  scope: resourceGroupNetworkSpokeBCDR
  name: '${spokeCAFPrefixesBCDR}vnet'
  params: {
    servicePrincipalAppId: servicePrincipalAppId
    spokeSubscriptionIds: spokeSubscriptionIdsBCDR
    // virtualWanHubId: virtualWanHubId
    nsgRules: nsgRules
    spokeAddressSpaces: spokeAddressSpacesBCDR
    spokeCAFPrefixes: spokeCAFPrefixesBCDR
    dnsServers: ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver)
    location: location
    subnets: ((enableSpokeSubnets == true) ? subnetsSpokePreconfigured : subnetsSpoke)
    tags: tags
  }
  dependsOn: [
  ]
}

// Build Dynamic Spoke Id Outputs

module dynamicSpokeIdsBCDR 'network/dynamicSubnets.bicep' = {
  scope: resourceGroupNetworkSpokeBCDR
  name: 'dynamicSubnets.bicep.dynamicSpokeIdsBCDR'
  params: {
    secret: secret
    tenantId: tenantId
    subscriptionId: spokeSubscriptionIdsBCDR
    servicePrincipalAppId: servicePrincipalAppId
    location: location
    virtualNetworkName: virtualNetworkSpokeBCDR.outputs.virtualNetworkNameSpoke
  }
  dependsOn: [
    virtualNetworkSpokeBCDR
  ]
}

// Virtual Network Connections initiated from VWAN

module coreHubToSpokeBCDR 'network/virtualWanHubPeering.bicep' = {
  scope: resourceGroup(vwanHubSubscriptionIds[0], '${vwanHubCAFPrefixes[0]}networkrg')
  name: '${vwanHubCAFPrefixes[1]}hub-to-${virtualNetworkSpokeBCDR.name}'
  params: {
    coreSubscriptionIds: coreSubscriptionIds
    virtualNetworkSpokeName: virtualNetworkSpokeBCDR.outputs.virtualNetworkNameSpoke
    virtualWanHubName: '${vwanHubCAFPrefixes[1]}hub'
    virtualNetworkSpokeId: virtualNetworkSpokeBCDR.outputs.virtualNetworkIdSpoke
    location: location
  }
  dependsOn: [
    virtualNetworkSpokeBCDR
  ]
}

// Deploy Common Subscription-wide Resources

module sharedResourcesBCDR 'subCommonResources.bicep' = {
  scope: subscription(spokeSubscriptionIdsBCDR)
  name: 'subNetworkSpokeBCDR.bicep.sharedResources'
  params: {
    pepSubnetId: dynamicSpokeIdsBCDR.outputs.azurePrivateEndpointSubnetId
    privateDNSZoneNameAutomation: privateDNSZoneNameAutomation
    privateDNSZoneNameKeyVault: privateDNSZoneNameKeyVault
    privateDNSZoneNameStorageBlob: privateDNSZoneNameStorageBlob
    privateDNSZoneNameStorageFile: privateDNSZoneNameStorageFile
    privateDNSZoneNameStorageTable: privateDNSZoneNameStorageTable
    privateDNSZoneNameStorageQueue: privateDNSZoneNameStorageQueue
    enableRecoveryServiceVault: enableRecoveryServiceVault
    spokeCAFPrefixes: spokeCAFPrefixesBCDR
    spokeCIDRPrefixes: spokeCIDRPrefixesBCDR
    location: location
    tenantId: tenantId
    tags: tags
  }
  dependsOn: [
    virtualNetworkSpokeBCDR
    dynamicSpokeIdsBCDR
    coreHubToSpokeBCDR
  ]
}

output virtualNetworkSpokeNameBCDR string = virtualNetworkSpokeBCDR.outputs.virtualNetworkNameSpoke
output virtualNetworkSpokeIdBCDR string = virtualNetworkSpokeBCDR.outputs.virtualNetworkIdSpoke
