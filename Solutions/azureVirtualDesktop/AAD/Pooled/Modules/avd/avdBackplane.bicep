param CAFPrefix string
param hostPoolUseCase string
param location string
// param tokenExpirationTime string
param personalDesktopAssignmentType string = 'Automatic'
param hostPoolType string
param maxSessionLimit int = 12
param loadBalancerType string
param logAnalyticsId string
param tags object
// param token string

var hostPoolName = '${CAFPrefix}${hostPoolUseCase}hp1'
var hostPoolFriendlyName = '${hostPoolUseCase}-Desktop'
var workspaceName = '${CAFPrefix}${hostPoolUseCase}ws1'
var appGroupFriendlyName= '${hostPoolUseCase} App Group'
var appGroupName = '${CAFPrefix}${hostPoolUseCase}dag1'

param baseTime string = utcNow('u')
var tokenExpirationTime = dateTimeAdd(baseTime, 'P30D')

resource hostPool 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' = {
  name: hostPoolName
  location: location
  tags: tags
  properties: {
    friendlyName: hostPoolFriendlyName
    hostPoolType: hostPoolType
    loadBalancerType: loadBalancerType
    preferredAppGroupType: 'Desktop'
    personalDesktopAssignmentType: personalDesktopAssignmentType
    maxSessionLimit: maxSessionLimit
    validationEnvironment: false
    registrationInfo: {
      expirationTime: tokenExpirationTime
      registrationTokenOperation: 'Update'
    }
  }
}

// Create Application Group (DAG)

resource applicationGroup 'Microsoft.DesktopVirtualization/applicationGroups@2019-12-10-preview' = {
  name: appGroupName
  location: location
  tags: tags
  properties: {
    friendlyName: appGroupFriendlyName
    applicationGroupType: 'Desktop'
    description: 'Deskop Application Group created through Abri Deploy process.'
    hostPoolArmPath: resourceId('Microsoft.DesktopVirtualization/hostpools', hostPoolName)
  }
  dependsOn: [
    hostPool
  ]
}

// Create Workspace

resource workspace 'Microsoft.DesktopVirtualization/workspaces@2019-12-10-preview' =  {
  name: workspaceName
  location: location
  tags:tags
  dependsOn: [
    applicationGroup
  ]
}

// Configure Log Analytics Account

module Monitoring './monitoring.bicep' = {
  name: 'Monitoring'
  params: {
    location: location
    hostpoolName: hostPoolName
    workspaceName: workspaceName
    logAnalyticsId:logAnalyticsId
  }
  dependsOn: [
    workspace
    // hostPool
  ]
}

output appGroupName string = appGroupName
output hostPoolName string = hostPoolName
output token string = reference(hostPoolName).registrationInfo.Token



