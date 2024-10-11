
param location string
param logAnalyticsName string

@allowed([
  'AgentHealthAssessment'
  'AntiMalware'
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAssessment'
  'Updates'
  'VMInsights'
])
@description('Solutions that will be added to the Log Analytics Workspace. - DEFAULT VALUE: [AgentHealthAssessment, AntiMalware, AzureActivity, ChangeTracking, Security, SecurityInsights, ServiceMap, SQLAssessment, Updates, VMInsights]')
param logAnalyticsWorkspaceSolutions array = [
  'AgentHealthAssessment'
  'AntiMalware'
  'AzureActivity'
  'ChangeTracking'
  'Security'
  'SecurityInsights'
  'ServiceMap'
  'SQLAssessment'
  'Updates'
  'VMInsights'
]

resource workspaces 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
}

resource resLogAnalyticsWorkspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in logAnalyticsWorkspaceSolutions: if (!empty(logAnalyticsWorkspaceSolutions)) {
  name: '${solution}(${workspaces.name})'
  location: location
  properties: {
    workspaceResourceId: workspaces.id
  }
  plan: {
    name: '${solution}(${workspaces.name})'
    product: 'OMSGallery/${solution}'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}]

output logAnalyticsId string = workspaces.id
output logAnalyticsName string = workspaces.name
