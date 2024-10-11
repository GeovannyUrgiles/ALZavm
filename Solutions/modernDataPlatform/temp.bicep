param sites_da_test_wus2_app01_name string = 'da-test-wus2-app01'
param serverfarms_da_test_wus2_func01_asp_externalid string = '/subscriptions/5fd55dd9-d76e-48b3-86f5-66638a425f9c/resourceGroups/da-test-wus2-rg/providers/Microsoft.Web/serverfarms/da-test-wus2-func01-asp'
param virtualNetworks_da_test_wus2_vnet_externalid string = '/subscriptions/5fd55dd9-d76e-48b3-86f5-66638a425f9c/resourceGroups/da-test-wus2-rg/providers/Microsoft.Network/virtualNetworks/da-test-wus2-vnet'
param userAssignedIdentities_da_test_wus2_mi01_externalid string = '/subscriptions/5fd55dd9-d76e-48b3-86f5-66638a425f9c/resourceGroups/da-test-wus2-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/da-test-wus2-mi01'

resource sites_da_test_wus2_app01_name_resource 'Microsoft.Web/sites@2023-12-01' = {
  name: sites_da_test_wus2_app01_name
  location: 'West US 2'
  kind: 'app'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/5fd55dd9-d76e-48b3-86f5-66638a425f9c/resourcegroups/da-test-wus2-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/da-test-wus2-mi01': {}
    }
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_da_test_wus2_app01_name}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_da_test_wus2_app01_name}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_da_test_wus2_func01_asp_externalid
    reserved: false
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      acrUseManagedIdentityCreds: false
      alwaysOn: true
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: 'EF56F102D17BB625988E5A80B54331587180E7572DEFCF4CCFEEFECF4B5A77B4'
    containerSize: 256
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Disabled'
    storageAccountRequired: false
    virtualNetworkSubnetId: '${virtualNetworks_da_test_wus2_vnet_externalid}/subnets/functionAppSN01'
    keyVaultReferenceIdentity: userAssignedIdentities_da_test_wus2_mi01_externalid
  }
}

resource sites_da_test_wus2_app01_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_da_test_wus2_app01_name_resource
  name: 'ftp'
  location: 'West US 2'
  properties: {
    allow: true
  }
}

resource sites_da_test_wus2_app01_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_da_test_wus2_app01_name_resource
  name: 'scm'
  location: 'West US 2'
  properties: {
    allow: true
  }
}

resource sites_da_test_wus2_app01_name_web 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: sites_da_test_wus2_app01_name_resource
  name: 'web'
  location: 'West US 2'
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
    netFrameworkVersion: 'v6.0'
    phpVersion: '5.6'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2022'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$da-test-wus2-app01'
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
    vnetName: 'bf78ccba-4504-415b-9564-391f9f06dcf9_functionAppSN01'
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    publicNetworkAccess: 'Disabled'
    localMySqlEnabled: false
    xManagedServiceIdentityId: 12363
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
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

resource sites_da_test_wus2_app01_name_sites_da_test_wus2_app01_name_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: sites_da_test_wus2_app01_name_resource
  name: '${sites_da_test_wus2_app01_name}.azurewebsites.net'
  location: 'West US 2'
  properties: {
    siteName: 'da-test-wus2-app01'
    hostNameType: 'Verified'
  }
}

resource sites_da_test_wus2_app01_name_sites_da_test_wus2_app01_name_azurewebites_pe01_16f7f823_3afa_47ad_b3aa_b0d9ca8dc95e 'Microsoft.Web/sites/privateEndpointConnections@2023-12-01' = {
  parent: sites_da_test_wus2_app01_name_resource
  name: '${sites_da_test_wus2_app01_name}-azurewebites-pe01-16f7f823-3afa-47ad-b3aa-b0d9ca8dc95e'
  location: 'West US 2'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      actionsRequired: 'None'
    }
    ipAddresses: [
      '10.152.52.8'
    ]
  }
}

resource sites_da_test_wus2_app01_name_bf78ccba_4504_415b_9564_391f9f06dcf9_functionAppSN01 'Microsoft.Web/sites/virtualNetworkConnections@2023-12-01' = {
  parent: sites_da_test_wus2_app01_name_resource
  name: 'bf78ccba-4504-415b-9564-391f9f06dcf9_functionAppSN01'
  location: 'West US 2'
  properties: {
    vnetResourceId: '${virtualNetworks_da_test_wus2_vnet_externalid}/subnets/functionAppSN01'
    isSwift: true
  }
}
