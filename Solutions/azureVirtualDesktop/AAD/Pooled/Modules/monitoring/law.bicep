param customerNaming string
param location string
param tags object

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${customerNaming}law'
  location: location
  tags: tags
}

output lawId string = law.id

