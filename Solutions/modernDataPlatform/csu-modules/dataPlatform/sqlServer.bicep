param pepSubnetId string
param sqlServerName string
param productionSKUs bool = false
// @secure()
// param SQLAdminUser string
// @secure()
// param SQLAdminPass string
param sqlDatabases array
param location string
param tags object
param userAssignedIdentityId string
param privateDnsZoneIdSql string
param privateDnsZoneNameSql string
param dataAdminGroupName string
param dataAdminGroupId string

// Local Variables
var backups = productionSKUs ? 'Geo' : 'Local'
var skuCapacity = productionSKUs ? 30 : 10
var skuName = productionSKUs ? 'GP_S_Gen5' : 'GP_S_Gen5' // SKUs: ElasticPool | StandardPool | GP_S_Gen5
var skuTier = productionSKUs ? 'Premium' : 'GeneralPurpose'
var skuFamily = productionSKUs ? 'Gen5' : 'Gen5'
var zoneRedundant = productionSKUs == true ? true : false

// Create Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  location: location
  tags: tags
  name: sqlServerName
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    // administratorLogin: SQLAdminUser
    // administratorLoginPassword: SQLAdminPass
    administrators: {
      login: dataAdminGroupName
      sid: dataAdminGroupId
      tenantId: tenant().tenantId
      principalType: 'Group'
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
    }
    version: '12.0'
    publicNetworkAccess: 'Disabled'
    primaryUserAssignedIdentityId: userAssignedIdentityId
    restrictOutboundNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
  }
}

// Add Data Team Entra Groups to SQL Admins
// resource administrators 'Microsoft.Sql/servers/administrators@2023-08-01-preview' = {
//   parent: sqlServer
//   name: 'ActiveDirectory'
//   properties: {
//     // principalType: 'Group'
//     administratorType: 'ActiveDirectory'
//     login: dataAdminGroupName
//     sid: dataAdminGroupId
//     tenantId: tenant().tenantId
//     // azureADOnlyAuthentication: false
//   }
// }

// Create Database(s)
resource databases 'Microsoft.Sql/servers/databases@2023-08-01-preview' = [
  for sqlDatabase in sqlDatabases: {
    parent: sqlServer
    name: sqlDatabase
    location: location
    sku: {
      name: skuName
      tier: skuTier
      family: skuFamily
      capacity: skuCapacity
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      maxSizeBytes: 268435456000
      catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
      readScale: 'Disabled'
      requestedBackupStorageRedundancy: backups
      isLedgerOn: false
      zoneRedundant: zoneRedundant
      autoPauseDelay: 60
      minCapacity: json('1.25')
      availabilityZone: 'NoPreference'
    }
    dependsOn: []
  }
]

// Create Private Endpoint
resource privateendpoints 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${sqlServerName}-pe01'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${sqlServerName}-pe01'
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${sqlServerName}-pe-nic01'
    ipConfigurations: []
    customDnsConfigs: []
  }
  dependsOn: []
}

// Private DNS Zone Groups
resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  name: 'dns-sqlserver'
  parent: privateendpoints
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneNameSql
        properties: {
          privateDnsZoneId: privateDnsZoneIdSql
        }
      }
    ]
  }
}
