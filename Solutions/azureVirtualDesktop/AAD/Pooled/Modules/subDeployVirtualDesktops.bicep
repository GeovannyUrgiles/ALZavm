targetScope = 'subscription'

param CAFPrefix string
param artifactsLocation string
param privateDNSZoneIdStorageFile string
param logAnalyticsId string
param hostPoolUseCase string
param location string
param baseTime string
param startDate string
param tags object
param pepSubnetId string
param hostPoolType string
param personalDesktopAssignmentType string
param maxSessionLimit int
param loadBalancerType string
param domainToJoin string
param ouPath string
param domainJoinOptions int
param AVDnumberOfInstances int
param virtualMachinePrefix string
param virtualMachineDiskType string
param virtualMachineSKU string
param marketplaceImage object
param subnetId string
param resourceGroupName string

// Create AVD Resource Group

resource avdResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' ={
  name: resourceGroupName
  location: location
  tags: tags
}

// Identify Key Vault containing Domain Join Credentials

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'nbbprdcorekv'
  scope: resourceGroup('2d2690e3-bc33-4d4b-b5fd-8b5555514a52','nbbprdcorerg')
}
/*
// Create Storage Account for FSLogix Pooled Profiles

module storageAccount 'avd/storageAccount.bicep' = {
  scope: avdResourceGroup
  name: 'main.bicep.storageAccount-${startDate}'
  params: {
    privateDNSZoneIdStorageFile: privateDNSZoneIdStorageFile
    CAFPrefix: CAFPrefix
    pepSubnetId: pepSubnetId
    location: location
    tags: tags
  }
}
*/
// Create Hostpool
module hostPool 'hostpools/pooled.bicep' = {
  name: 'main.bicep.hostPool.bicep-${startDate}'
  scope: avdResourceGroup
  params: {
    CAFPrefix: CAFPrefix
    hostPoolUseCase: hostPoolUseCase
    location: location
    baseTime: baseTime
    tags: tags
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    personalDesktopAssignmentType: personalDesktopAssignmentType
    maxSessionLimit: maxSessionLimit
  }
  dependsOn: [
   ]
}

// Create Backplane
module avdBackplane 'avd/avdBackplane.bicep' = {
  name: 'main.bicep.avdBackplane-${startDate}'
  scope: avdResourceGroup
  params: {
    CAFPrefix: CAFPrefix
    hostPoolUseCase: hostPoolUseCase
    location: location
    tags: tags
    logAnalyticsId: logAnalyticsId
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    personalDesktopAssignmentType: personalDesktopAssignmentType
    maxSessionLimit: maxSessionLimit
  }
  dependsOn: [
    hostPool
   ]
}

// Create Session Hosts
module VMs 'virtualMachines/multisession.bicep' = {
  scope: avdResourceGroup
  name: 'DeployVMs-${startDate}'
  params: {
    administratorAccountUserName: keyVault.getSecret('domainlogin')
    administratorAccountPassword: keyVault.getSecret('domainpass')
    artifactsLocation: artifactsLocation
    AVDnumberOfInstances: AVDnumberOfInstances
    domainToJoin: domainToJoin
    ouPath: ouPath
    //domainJoinOptions: domainJoinOptions
    hostPoolName: avdBackplane.outputs.hostPoolName
    location: location
    marketplaceImage: marketplaceImage
    token: avdBackplane.outputs.token
    subnetID: subnetId
    virtualMachineDiskType: virtualMachineDiskType
    virtualMachinePrefix: virtualMachinePrefix
    virtualMachineSKU: virtualMachineSKU
  }
  dependsOn: [
    avdBackplane
  ]
}
