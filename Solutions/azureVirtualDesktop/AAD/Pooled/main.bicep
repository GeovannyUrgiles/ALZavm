targetScope = 'subscription'

param CAFPrefix string = 'nbbprdwus' // naming convention for client (ex. neuprdwus3avd)
param artifactsLocation string = 'https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip'
param subscriptionId string = '2d2690e3-bc33-4d4b-b5fd-8b5555514a52'
param virtualNetworkResourceGroup string = '${CAFPrefix}networkrg'
param virtualNetworkName string = '${CAFPrefix}vnet01'
param AzureAVDSubnetName string = '${CAFPrefix}avdsn'
param AzurePrivateEndpointSubnetName string = '${CAFPrefix}pepsn'
param logAnalyticsId string = '/subscriptions/f4f75cf1-e082-4aab-b5ff-0c35dbc7f62e/resourceGroups/nbbcorwuslogrg/providers/Microsoft.OperationalInsights/workspaces/nbbcorwuslaw01'
param privateDNSZoneIdStorageFile string = '/subscriptions/f4f75cf1-e082-4aab-b5ff-0c35dbc7f62e/resourceGroups/nbbcorwusnetworkrg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'

@allowed([
  'nbbinternal'
  'nbbexternal'
  'nbbcloud'
])
param hostPoolUseCase string = toLower('nbbcloud')
param location string = 'westus'
// param baseTime string = utcNow('u')

param baseTime string = utcNow('u')
param startDate string = utcNow('yyyyMMdd-HHmmss')
param tags object = {
  // Confidentiality: ''
  // Criticality: ''
  // Ticket: ''
}

// Type of Hostpool to be deployed

@allowed([
  'Pooled'
  'Persistent'
])
param hostPoolType string = 'Pooled'

// User Assignment Type

@allowed([
  'Automatic'
  'Direct'
])
param personalDesktopAssignmentType string = 'Automatic'

// Maximum Number of Users per Pool before spinning up another Pool Member

param maxSessionLimit int = 8

@allowed([
  'BreadthFirst'
  'DepthFirst'
  'Persistent'
])
param loadBalancerType string = 'DepthFirst'

// Use FQDN for Domain Name to Join, not NETBIOS name
// Also, Key Vault Credentials should be in UPN format

param domainToJoin string = 'newbelgium.com'
param ouPath string = 'OU=Pooled-CloudInternal,OU=AzureVirtualDesktops,OU=New Belgium Workstations,DC=newbelgium,DC=com'
param domainJoinOptions int = 3

// Virtual Machine Details

param AVDnumberOfInstances int = 3
param virtualMachinePrefix string = 'nbbavdcld'
@allowed([
  'Premium_LRS'
  'UltraSSD_LRS'
  'Premium_ZRS'
  'StandardSSD_ZRS'
  'StandardSSD_LRS'
])
param virtualMachineDiskType string = 'Premium_LRS'
param virtualMachineSKU string = 'Standard_D8s_V5'

// Private Endpoint Subnet ID

param AzurePrivateEndpointSubnetId string = '/subscriptions/${subscriptionId}/resourceGroups/${virtualNetworkResourceGroup}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${AzurePrivateEndpointSubnetName}'

// Marketplace Offer

param marketplaceImage object = {
  publisher: 'MicrosoftWindowsDesktop'
  offer: 'office-365'
  sku: '20h2-evd-o365pp'
  version: 'latest'
}

// Subnet ID

param subnetId string = '/subscriptions/${subscriptionId}/resourceGroups/${virtualNetworkResourceGroup}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${AzureAVDSubnetName}'

// var unique = uniqueString(subscription().displayName)
param resourceGroupName string = '${CAFPrefix}avdrg03'

// Create AVD Hostpool 
module hostPool 'Modules/subDeployVirtualDesktops.bicep' = {
  name: 'main.subDeployVirtualDesktops.bicep-${startDate}'
  scope: subscription(subscriptionId)
  params: {
    CAFPrefix: CAFPrefix
    pepSubnetId: AzurePrivateEndpointSubnetId
    hostPoolUseCase: hostPoolUseCase
    privateDNSZoneIdStorageFile: privateDNSZoneIdStorageFile
    location: location
    tags: tags
    artifactsLocation: artifactsLocation
    AVDnumberOfInstances: AVDnumberOfInstances
    baseTime: baseTime
    startDate: startDate
    logAnalyticsId: logAnalyticsId
    domainToJoin: domainToJoin
    virtualMachineDiskType: virtualMachineDiskType
    hostPoolType: hostPoolType
    domainJoinOptions: domainJoinOptions
    loadBalancerType: loadBalancerType
    personalDesktopAssignmentType: personalDesktopAssignmentType
    maxSessionLimit: maxSessionLimit
    subnetId: subnetId
    resourceGroupName: resourceGroupName
    marketplaceImage: marketplaceImage
    virtualMachinePrefix: virtualMachinePrefix
    ouPath: ouPath
    virtualMachineSKU: virtualMachineSKU
  }
  dependsOn: [
    
   ]
}
