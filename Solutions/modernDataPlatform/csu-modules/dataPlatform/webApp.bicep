param location string
param pepSubnetId string
param tags object
param serverfarmsId string
param componentsName string = webAppName
param logAnalyticsWorkspaceId string
param webAppName string
param privateDnsZoneIdWebsites string
param privateDnsZoneNameWebsites string
param userAssignedIdentityId string
param functionAppSubnetId string

// Deploy Web Apps
resource sites 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  tags: tags
  kind: 'app'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarmsId
    reserved: false
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: true
    vnetImagePullEnabled: false
    vnetContentShareEnabled: true
    vnetBackupRestoreEnabled: true
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      phpVersion: '5.6'
      appSettings: [
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    containerSize: 256
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Disabled'
    storageAccountRequired: false
    virtualNetworkSubnetId: functionAppSubnetId
    keyVaultReferenceIdentity: userAssignedIdentityId
  }
}

// FTP Publishing Credentials
resource basicPublichingCredentialsPolicies_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites
  // location: location
  name: 'ftp'
  properties: {
    allow: true
  }
}

// SCM Publiching Credentials
resource basicPublichingCredentialsPolicies_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites
  // location: location
  name: 'scm'
  properties: {
    allow: true
  }
}

// sites Config
resource sitesConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: sites
  name: 'web'
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2022'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: true
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Disabled'
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

// Host Binding
resource hostNamesBindings 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: sites
  name: '${webAppName}.azurewebsites.net'
  properties: {
    siteName: webAppName
  }
}

// Virtual Network Integration / Network Injection
resource virtualNetworkConnections 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = {
  parent: sites
  name: 'virtualNetworkConnections.${webAppName}'
  properties: {
    vnetResourceId: functionAppSubnetId
    isSwift: true
  }
}

// Private Endpoints
resource privateEndpoints 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: '${webAppName}-azurewebsites-pe01'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${webAppName}-azurewebites-pe01'
        properties: {
          privateLinkServiceId: sites.id
          groupIds: [
            'sites'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: pepSubnetId
    }
    customNetworkInterfaceName: '${webAppName}-azurewebsites-pe-nic01'
    ipConfigurations: []
    customDnsConfigs: []
  }
}

// Private DNS Zone Groups
resource privateDnsZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: privateEndpoints
  name: privateDnsZoneNameWebsites
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink.azurewebsites.net-config'
        properties: {
          privateDnsZoneId: privateDnsZoneIdWebsites
        }
      }
    ]
  }
  dependsOn: []
}

// Application Insights
resource components 'microsoft.insights/components@2020-02-02' = {
  name: componentsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}
