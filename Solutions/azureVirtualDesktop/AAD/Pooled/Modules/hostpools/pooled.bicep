param CAFPrefix string
param hostPoolUseCase string
param location string
param personalDesktopAssignmentType string = 'Automatic'
param hostPoolType string
param maxSessionLimit int = 12
param loadBalancerType string
param tags object

var hostPoolName = '${CAFPrefix}${hostPoolUseCase}hp1'
var hostPoolFriendlyName = '${hostPoolUseCase}-desktop'

param baseTime string = utcNow('u')
var tokenExpirationTime = dateTimeAdd(baseTime, 'P30D')

resource hostPools 'Microsoft.DesktopVirtualization/hostPools@2021-07-12' = {
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
      token: null
      registrationTokenOperation: 'Update'
    }
  }
}

output hostPoolName string = hostPoolName
output token string = reference(hostPoolName).registrationInfo.Token
