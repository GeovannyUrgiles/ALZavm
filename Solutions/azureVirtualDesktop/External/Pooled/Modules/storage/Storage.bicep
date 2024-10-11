param location string
param customerNaming string
param tags object

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: '${customerNaming}poolsa'
  location: location
  tags: tags
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'FileStorage'
}
