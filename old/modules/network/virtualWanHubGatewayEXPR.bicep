param erPeeringLocation string
param erCircuitName string
param serviceProviderName string
param erSKU_Tier string
param erSKU_Family string
param gatewaySku string
param gatewayName string
param location string
param bandwidthInMbps int

var erSKU_Name = '${erSKU_Tier}_${erSKU_Family}'
var gatewayPublicIPName = '${gatewayName}pip'
var nsgName = 'nsg'

resource erCircuit 'Microsoft.Network/expressRouteCircuits@2021-05-01' = {
  name: erCircuitName
  location: location
  sku: {
    name: erSKU_Name
    tier: erSKU_Tier
    family: erSKU_Family
  }
  properties: {
    serviceProviderProperties: {
      serviceProviderName: serviceProviderName
      peeringLocation: erPeeringLocation
      bandwidthInMbps: bandwidthInMbps
    }
    allowClassicOperations: false
  }
}
