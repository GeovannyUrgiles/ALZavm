param logAnalyticsWorkspaceName string
param automationAccountId string

// Add to Operational Insights
resource workspaces 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

// Link to Automation Account
resource linkedServices 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = {
  parent: workspaces
  name: 'Automation'
  properties: {
    resourceId: automationAccountId
  }
}
