param adlsName string
param location string
param tags object
param env string

param privateDnsZoneIdFile string
param privateDnsZoneIdBlob string
param privateDnsZoneIdTable string
param privateDnsZoneIdQueue string
param privateDnsZoneIdDfs string

param privateDnsZoneIdSql string
param privateDnsZoneIdWebsites string
param privateDnsZoneNameBlob string
param privateDnsZoneNameDfs string
param privateDnsZoneNameFile string
param privateDnsZoneNameQueue string
param privateDnsZoneNameTable string
param privateDnsZoneNameSql string
param privateDnsZoneNameWebsites string


param dataLakeSubResourceNames array
param userAssignedIdentityId string
param dataLakeStorageFrameworkContainerName string
param dataLakeStorageFlatfileContainerName string
param dataLakeStorageDefaultContainerName string
param sqlServerName string
param sqlDatabases array
param logAnalyticsWorkspaceId string

param dataResourceGroupName string
param keyVaultName string
param keyName string
param pepSubnetId string
param functionAppName string
param functionAppSubnetId string
param webAppName string

param dataAdminGroupName string
param dataAdminGroupId string
param managedIdentityName string

param bypassFunctionApp bool
param bypassWebApp bool
param bypassAzureSQL bool
param bypassDatalake bool
param bypassRoles bool

param productionSKUs bool
param sku object

// Reference existing Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  scope: resourceGroup(dataResourceGroupName)
  name: keyVaultName
}

// Create Data Lake Storage
module dataLake 'dataPlatform/dataLake.bicep' = if (bypassDatalake == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-dataLake'
  params: {
    adlsName: adlsName
    location: location 
    tags: tags
    pepSubnetId: pepSubnetId
    privateDnsZoneIdFile: privateDnsZoneIdFile
    privateDnsZoneIdBlob: privateDnsZoneIdBlob
    privateDnsZoneIdTable: privateDnsZoneIdTable
    privateDnsZoneIdQueue: privateDnsZoneIdQueue
    privateDnsZoneIdDfs: privateDnsZoneIdDfs
    privateDnsZoneNameBlob: privateDnsZoneNameBlob
    privateDnsZoneNameDfs: privateDnsZoneNameDfs
    privateDnsZoneNameFile: privateDnsZoneNameFile
    privateDnsZoneNameQueue: privateDnsZoneNameQueue
    privateDnsZoneNameTable: privateDnsZoneNameTable
    dataLakeSubResourceNames: dataLakeSubResourceNames
    dataLakeStorageFrameworkContainerName: dataLakeStorageFrameworkContainerName
    dataLakeStorageFlatfileContainerName: dataLakeStorageFlatfileContainerName
    dataLakeStorageDefaultContainerName: dataLakeStorageDefaultContainerName
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    managedIdentityName: managedIdentityName
    dataResourceGroupName: dataResourceGroupName
    keyName: keyName
    keyVaultName: keyVaultName
  }
  dependsOn: [
    
  ]
}

// Function App
module functionApp 'dataPlatform/functionApp.bicep' = if (bypassFunctionApp == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-funcApp'
  params: {
    functionAppName: functionAppName
    location: location
    tags: tags
    keyVaultName: keyVaultName
    keyName: keyName
    functionAppSubnetId: functionAppSubnetId
    pepSubnetId: pepSubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    privateDnsZoneIdWebsites: privateDnsZoneIdWebsites
    privateDnsZoneNameWebsites: privateDnsZoneNameWebsites
    privateDnsZoneIdBlob: privateDnsZoneIdBlob
    privateDnsZoneIdFile: privateDnsZoneIdFile
    privateDnsZoneIdTable: privateDnsZoneIdTable
    privateDnsZoneIdQueue: privateDnsZoneIdQueue
    dataResourceGroupName: dataResourceGroupName
    privateDnsZoneNameBlob: privateDnsZoneNameBlob
    privateDnsZoneNameFile: privateDnsZoneNameFile
    privateDnsZoneNameQueue: privateDnsZoneNameQueue
    privateDnsZoneNameTable: privateDnsZoneNameTable
    userAssignedIdentityId: userAssignedIdentityId
    managedIdentityName: managedIdentityName
    productionSkus: productionSKUs
    sku: sku
    env: env
  }
  dependsOn: [
  ]
}

// Web App
module webApp 'dataPlatform/webApp.bicep' = if (bypassWebApp == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-webApp'
  params: {
    webAppName: webAppName
    location: location
    tags: tags
    serverfarmsId: functionApp.outputs.serverfarmsId
    functionAppSubnetId: functionAppSubnetId
    pepSubnetId: pepSubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    privateDnsZoneIdWebsites: privateDnsZoneIdWebsites
    privateDnsZoneNameWebsites: privateDnsZoneNameWebsites
    userAssignedIdentityId: userAssignedIdentityId
  }
  dependsOn: [
    functionApp
  ]
}

// SQL Key for CMK
resource keyVaultKey 'Microsoft.KeyVault/vaults/keys@2024-04-01-preview' existing = if (bypassAzureSQL == false) {
  name: keyName
  parent: keyVault
}

// Existing User Assigned Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  scope: resourceGroup(dataResourceGroupName)
  name: managedIdentityName
}

// Create Azure SQL Server
module sqlServer 'dataPlatform/sqlServer.bicep' = if (bypassAzureSQL == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-sqlServer'
  params: {
    pepSubnetId: pepSubnetId
    productionSKUs: productionSKUs
    sqlServerName: sqlServerName
    sqlDatabases: sqlDatabases
    location: location
    tags: tags
    privateDnsZoneIdSql: privateDnsZoneIdSql
    privateDnsZoneNameSql: privateDnsZoneNameSql
    userAssignedIdentityId: userAssignedIdentity.id
    dataAdminGroupName: dataAdminGroupName
    dataAdminGroupId: dataAdminGroupId
  }
  dependsOn: [
    functionApp
    webApp
  ]
}

// Add SQL TDE Encryption
module sqlServerProtect 'dataPlatform/sqlServerProtect.bicep' = if (bypassAzureSQL == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-sqlDbEncrypt'
  params: {
    sqlServerName: sqlServerName
    keyName: keyName
    keyVaultName: keyVaultName
    keyVersion:  last(split(keyVaultKey.properties.keyUriWithVersion, '/'))
    keyUri: keyVaultKey.properties.keyUriWithVersion
    autoRotationEnabled: true
  }
  dependsOn: [
    sqlServer
  ]
}


module rolesResourceGroup 'identity/rolesFunctionApp.bicep' = if (bypassRoles == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-rolesFunctionApp'
  params: {
    systemAssignedIdentityPrincipalId: functionApp.outputs.systemAssignedIdentityId
  }
  dependsOn: [
    functionApp
  ]
}

// Add Connection Strings to Key Vault
module addConnectionStrings 'dataPlatform/addConnectionStrings.bicep' = if (bypassFunctionApp == false) {
  scope: resourceGroup(dataResourceGroupName)
  name: '${env}-connectionStrings'
  params: {
    sqlDatabases: sqlDatabases
    sqlServerName: sqlServerName
    env: env
    keyVaultName: keyVaultName
    storageAccountName: adlsName //.name
  }
  dependsOn: [
    sqlServer
  ]
}
