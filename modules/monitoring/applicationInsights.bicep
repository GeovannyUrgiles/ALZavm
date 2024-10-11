param applicationInsightsName string
param workspaceResourceId string
param location string
param tags object

resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  tags: tags
  kind: 'other'
  etag: 'core'
  properties: {
    Application_Type: 'other'
    DisableIpMasking: true
    DisableLocalAuth: true
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: true
    HockeyAppId: 'tforce'
    ImmediatePurgeDataOn30Days: true
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
    Request_Source: 'rest'
    RetentionInDays: 30
    SamplingPercentage: 50
    WorkspaceResourceId: workspaceResourceId
  }
  dependsOn: [
    
  ]
}
output applicationInsightsId string = appinsights.id
