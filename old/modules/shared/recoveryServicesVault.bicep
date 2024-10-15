param spokeCAFPrefixes string

param enableCRR bool = false

@allowed([
  'LocallyRedundant'
  'GeoRedundant'
])
param vaultStorageType string = 'LocallyRedundant'

param location string
param tags object

var skuName = 'RS0'
var skuTier = 'Standard'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-02-01' = {
  name: '${spokeCAFPrefixes}rsv'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {}
}

resource recoveryservicesvaultstorageconfig 'Microsoft.RecoveryServices/vaults/backupstorageconfig@2022-02-01' = {
  parent: recoveryServicesVault
  name: 'vaultstorageconfig'
  properties: {
    storageModelType: vaultStorageType
    crossRegionRestoreFlag: enableCRR
  }
}
