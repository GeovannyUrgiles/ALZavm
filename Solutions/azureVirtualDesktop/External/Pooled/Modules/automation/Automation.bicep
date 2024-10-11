param customerNaming string
param location string

resource automation_account 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: '${customerNaming}aa01'
  location: location
  tags: {}
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Basic'
    }
    publicNetworkAccess: true
  }
  dependsOn: []
}

