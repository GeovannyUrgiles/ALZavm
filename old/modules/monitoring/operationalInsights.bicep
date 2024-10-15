resource operationalInsights 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'string'
  location: location
  eTag: 'string'
  properties: {
    defaultDataCollectionRuleResourceId: 'string'
    features: {
      clusterResourceId: 'string'
      disableLocalAuth: bool
      enableDataExport: bool
      enableLogAccessUsingOnlyResourcePermissions: bool
      immediatePurgeDataOn30Days: bool
    }
    forceCmkForQuery: bool
    publicNetworkAccessForIngestion: 'string'
    publicNetworkAccessForQuery: 'string'
    retentionInDays: int
    sku: {
      capacityReservationLevel: int
      name: 'string'
    }
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}
