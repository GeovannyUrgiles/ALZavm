param serverfarmsName string
param location string
param tags object
param sku object

// App Service Plan
resource serverfarms 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: serverfarmsName
  location: location
  tags: tags
  sku: sku
  kind: 'app'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

output serverfarmsId string = serverfarms.id
output serverfarmsName string = serverfarms.name
