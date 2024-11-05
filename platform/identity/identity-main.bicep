targetScope = 'subscription'

// Deployment Boolean Parameters

param enableIdentity bool
param enableNetworkSecurityGroups bool
param enableNetwork bool
param enableMonitoring bool
param enableKeyVault bool
param enableStorage bool
param enableSiteRecovery bool
param enableDomainController bool

// Deployment Options

param subscriptionId string
param conSubscriptionId string
param locations array
param locationsShort array
param tags object
param nameSeparator string

// Private DNS Zone Location

param resourceGroupName_PrivateDns string

// Resource Names

param uamiName array
param operationalInsightsName array
param keyVaultName array
param storageAccountName array
param availabilitySetName array
param virtualMachineName_Windows array
param dataCollectionRuleName array
param recoveryServiceVaultName array

// DNS Servers

param dnsServers array

// Resource Maps

param keyVault keyVaultType
type keyVaultType = {
  sku: 'standard' | 'premium' // standard | premium (lowercase) (premium SKU requires HSM)
  accessPolicies: array
  publicNetworkAccess: 'Enabled' | 'Disabled'
  bypass: 'AzureServices' | 'None'
  defaultAction: 'Allow' | 'Deny'
  ipRules: array
  virtualNetworkRules: array
  enablePurgeProtection: bool
  softDeleteRetentionInDays: int
  enableRbacAuthorization: bool
}
param storageAccount storageAccountType
type storageAccountType = {
  accountTier: 'Standard' | 'Premium'
  requireInfrastructureEncryption: bool
  sasExpirationPeriod: string
  skuName:
    | 'Premium_LRS'
    | 'Premium_ZRS'
    | 'Standard_GRS'
    | 'Standard_GZRS'
    | 'Standard_LRS'
    | 'Standard_RAGRS'
    | 'Standard_RAGZRS'
    | 'Standard_ZRS'
  accountReplicationType: 'LRS' | 'GRS' | 'RAGRS' | 'ZRS' | 'GZRS' | 'RA_GRS'
    accountKind: 'Storage' | 'StorageV2' | 'BlobStorage' | 'BlockBlobStorage'
  accountAccessTier: 'Hot' | 'Cool' | 'Archive'
  allowBlobPublicAccess: bool
  blobServices: {
    automaticSnapshotPolicyEnabled: bool
    containerDeleteRetentionPolicyDays: int
    containerDeleteRetentionPolicyEnabled: bool
    containers: array
    deleteRetentionPolicyDays: int
    deleteRetentionPolicyEnabled: bool
  }
  enableHierarchicalNamespace: bool
  enableNfsV3: bool
  enableSftp: bool
  fileServices: {
    shareDeleteRetentionPolicyDays: int
    shares: array
  }
  largeFileSharesState: 'Enabled' | 'Disabled'
  localUsers: array
  managementPolicyRules: array
  networkAcls: {
    bypass: 'AzureServices' | 'None'
    defaultAction: 'Allow' | 'Deny'
    ipRules: array
  }
}
param recoveryServicesVault object

param availabilitySet availabilitySetType
type availabilitySetType = {
  proximityPlacementGroupResourceId: string
  platformFaultDomainCount: int
  platformUpdateDomainCount: int
}
param virtualMachine_Windows virtualMachineWindowsType
type virtualMachineWindowsType = {
  adminUsername: string
  enableAutomaticUpdates: bool
  encryptionAtHost: bool
  osType: 'Windows'
  backupPolicyName: string
  vmSize: 'Standard_DS1_v2' | 'Standard_DS2_v2' | 'Standard_DS3_v2' | 'Standard_DS4_v2' | 'Standard_DS5_v2' | 'Standard_DS11_v2' | 'Standard_DS12_v2' | 'Standard_DS13_v2' | 'Standard_DS14_v2' | 'Standard_DS15_v2' | 'Standard_D1_v2' | 'Standard_D2_v2' | 'Standard_D3_v2' | 'Standard_D4_v2' | 'Standard_D5_v2' | 'Standard_D11_v2' | 'Standard_D12_v2' | 'Standard_D13_v2' | 'Standard_D14_v2' | 'Standard_D15_v2' | 'Standard_D2s_v3' | 'Standard_D4s_v3' | 'Standard_D8s_v3' | 'Standard_D16s_v3' | 'Standard_D32s_v3' | 'Standard_D48s_v3' | 'Standard_D64s_v3' | 'Standard_D2_v3' | 'Standard_D4_v3' | 'Standard_D8_v3' | 'Standard_D16_v3' | 'Standard_D32_v3' | 'Standard_D48_v3' | 'Standard_D64_v3' | 'Standard_D2s_v4' | 'Standard_D4s_v4' | 'Standard_D8s_v4' | 'Standard_D16s_v4' | 'Standard_D32s_v4' | 'Standard_D48s_v4' | 'Standard_D64s_v4' | 'Standard_D2_v4' | 'Standard_D4_v4' | 'Standard_D8_v4' | 'Standard_D16_v4' | 'Standard_D32_v4' | 'Standard_D48_v4' | 'Standard_D64_v4' | 'Standard_D2ds_v4' | 'Standard_D4ds_v4' | 'Standard_D8ds_v4' | 'Standard_D16ds_v4' | 'Standard_D32ds_v4' | 'Standard_D48ds_v4' | 'Standard_D64ds_v4' | 'Standard_D2s_v5' | 'Standard_D4s_v5' | 'Standard_D8s_v5' | 'Standard_D16s_v5' | 'Standard_D32s_v5' | 'Standard_D48s_v5' | 'Standard_D64s_v5' | 'Standard_D2_v5' | 'Standard_D4_v5' | 'Standard_D8_v5' | 'Standard_D16_v5' | 'Standard_D32_v5' | 'Standard_D48_v5' | 'Standard_D64_v5' | 'Standard_D2ds_v5' | 'Standard_D4ds_v5' | 'Standard_D8ds_v5' | 'Standard_D16ds_v5' | 'Standard_D32ds_v5' | 'Standard_D48ds_v5' | 'Standard_D64ds_v5' | 'Standard_D2s_v6'
  zone: int
  imageReference: {
    offer: string
    publisher: string
    sku: string
    version: string
  }
  extensionAadJoinConfig: {
    enabled: bool
  }
  nicConfigurations: {
    deleteOption: 'Delete' | 'Detach'
    name: string
    enableIPForwarding: bool
    privateIpAddressVersion: 'IPv4' | 'IPv6'
    privateIPAllocationMethod: 'Dynamic' | 'Static'
  }
  osDisk: {
    caching: 'None' | 'ReadOnly' | 'ReadWrite'
    createOption: 'Attach' | 'FromImage' | 'Empty'
    deleteOption: 'Delete' | 'Detach'
    diskSizeGB: int
    managedDisk: {
      storageAccountType: 'Standard_LRS' | 'Premium_LRS' | 'StandardSSD_LRS' | 'UltraSSD_LRS'
    }
  }
  dataDisks: {
    caching: 'None' | 'ReadOnly' | 'ReadWrite'
    createOption: 'Attach' | 'FromImage' | 'Empty'
    deleteOption: 'Delete' | 'Detach'
    diskSizeGB: int
    lun: int
    managedDisk: {
      storageAccountType: 'Standard_LRS' | 'Premium_LRS' | 'StandardSSD_LRS' | 'UltraSSD_LRS'
    }
  }
  autoShutdownConfig: {
    dailyRecurrenceTime: string
    notificationEmail: string
    notificationLocale: string
    notificationStatus: 'Enabled' | 'Disabled'
    notificationTimeInMinutes: int
    status: 'Enabled' | 'Disabled'
    timeZone: 'UTC' | 'Central Standard Time' | 'Eastern Standard Time' | 'Pacific Standard Time' | 'Mountain Standard Time'
  }
  enableAutoUpdate: bool
  patchMode: 'AutomaticByPlatform' | 'AutomaticByOS' | 'Manual'
  rebootSetting: 'IfRequired' | 'Never'
  proximityPlacementGroupResourceId: string
  enableBackup: bool
  enableMonitoring: bool
  enableUpdateManagement: bool
  enableTelemetry: bool
  extensionAntiMalwareConfig: {
    enabled: bool
    settings: {
      AntimalwareEnabled: bool
      Exclusions: {
        Extensions: string
        Paths: string
        Processes: string
      }
      RealtimeProtectionEnabled: bool
      ScheduledScanSettings: {
        day: string
        isEnabled: bool
        scanType: 'Quick' | 'Full'
        time: string
      }
    }
  }
  extensionDependencyAgentConfig: {
    enableAMA: bool
    enabled: bool
    tags: object
  }
  extensionDSCConfig: {
    enabled: bool
    tags: object
  }
}

// Resource Suffixes

param nsgSuffix string
param peSuffix string
param nicSuffix string

// Resource Group Parameters

param resourceGroupName_Network array
param resourceGroupName_SiteRecovery array
param resourceGroupName_DomainController array
param resourceGroupName_Identity array

// Role Assignment Parameters

param roleAssignmentsNetwork array

param lock object

// Virtual Network Parameters

param virtualNetwork array
param subnets0 array
param subnets1 array

// Network Security Group Parameters

param securityRulesDefault array

// Network Resource Group Deployment
@description('Deploys a resource group for network resources.')
module modResourceGroupNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableNetwork) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupNetworkDeployment${i}'
    params: {
      name: resourceGroupName_Network[i]
      tags: tags
      location: locations[i]
      // lock: lock
      roleAssignments: roleAssignmentsNetwork
    }
  }
]
@description('Deploys a resource group for site recovery resources.')
module modResourceGroupSiteRecovery 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableSiteRecovery) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupASRDeployment${i}'
    params: {
      name: resourceGroupName_SiteRecovery[i]
      tags: tags
      location: locations[i]
      // lock: lock
      roleAssignments: roleAssignmentsNetwork
    }
  }
]
@description('Deploys a resource group for domain controller resources.')
module modResourceGroupDomainController 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableDomainController) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupDCDeployment${i}'
    params: {
      name: resourceGroupName_DomainController[i]
      tags: tags
      location: locations[i]
      // lock: lock
      roleAssignments: roleAssignmentsNetwork
    }
  }
]
@description('Deploys a resource group for identity resources.')
module modResourceGroupIdentity 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableIdentity) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupIdentityDeployment${i}'
    params: {
      name: resourceGroupName_Identity[i]
      tags: tags
      location: locations[i]
      // lock: lock
      roleAssignments: roleAssignmentsNetwork
    }
  }
]
@description('Deploys a user-assigned managed identity.')
module modUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = [
  for i in range(0, length(locations)): if (enableIdentity) {
    scope: resourceGroup(resourceGroupName_Identity[i])
    name: 'userAssignedIdentityDeployment${i}'
    params: {
      name: uamiName[i]
      tags: tags
      location: locations[i]
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

@description('Deploys a Log Analytics workspace.')
module modWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = [
  for i in range(0, length(locations)): if (enableMonitoring) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'workspaceDeployment'
    params: {
      name: operationalInsightsName[i]
      location: locations[i]
      tags: tags
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Network Security Groups - Primary Region
@description('Deploys a Network Security Groups (NSG) into the Primary Region.')
module modNetworkSecurityGroupPrimary 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnet in subnets0: if (enableNetworkSecurityGroups) {
    scope: resourceGroup(resourceGroupName_Network[0])
    name: 'nsgDeployment${subnet.name}'
    params: {
      name: toLower('${subnet.name}${nsgSuffix}')
      tags: tags
      location: locations[0]
      securityRules: securityRulesDefault
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Network Security Groups - Secondary Region
@description('Deploys a Network Security Groups (NSG) into the Secondary Region.')
module modNetworkSecurityGroupSecondary 'br/public:avm/res/network/network-security-group:0.5.0' = [
  for subnet in subnets1: if ((enableNetworkSecurityGroups) && length(locations) == 2) {
    scope: resourceGroup(resourceGroupName_Network[1])
    name: 'nsgDeployment${subnet.name}'
    params: {
      name: toLower('${subnet.name}${nsgSuffix}')
      tags: tags
      location: locations[1]
      securityRules: securityRulesDefault
    }
    dependsOn: [
      modResourceGroupNetwork
    ]
  }
]

// Virtual Network
@description('Deploys a Virtual Network (VNet).')
module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = [
  for i in range(0, length(locations)): if (enableNetwork) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'virtualNetworkDeployment${i}'
    params: {
      name: virtualNetwork[i].name
      location: locations[i]
      tags: tags
      addressPrefixes: virtualNetwork[i].addressPrefixes
      dnsServers: dnsServers
      subnets: (i == 0) ? subnets0 : subnets1
      diagnosticSettings: [
        {
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
    }
    dependsOn: [
      modNetworkSecurityGroupPrimary
      modNetworkSecurityGroupSecondary
    ]
  }
]

// Key Vault
@description('Deploys an Azure Key Vault.')
module modKeyVault 'br/public:avm/res/key-vault/vault:0.9.0' = [
  for i in range(0, length(locations)): if (enableKeyVault) {
    scope: resourceGroup(resourceGroupName_Identity[i])
    name: 'vaultDeployment${i}'
    params: {
      name: keyVaultName[i]
      location: locations[i]
      sku: keyVault.sku
      accessPolicies: keyVault.accessPolicies
      diagnosticSettings: [
        {
          logCategoriesAndGroups: [
            {
              category: 'AzurePolicyEvaluationDetails'
            }
            {
              category: 'AuditEvent'
            }
          ]
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
      enablePurgeProtection: keyVault.enablePurgeProtection
      enableRbacAuthorization: keyVault.enableRbacAuthorization
      roleAssignments: []
      secrets: []
      softDeleteRetentionInDays: keyVault.softDeleteRetentionInDays
      tags: tags
      keys: []
      lock: {}
      publicNetworkAccess: keyVault.publicNetworkAccess
      networkAcls: {
        bypass: keyVault.bypass
        defaultAction: keyVault.defaultAction
        ipRules: keyVault.ipRules
        virtualNetworkRules: keyVault.virtualNetworkRules
      }
      privateEndpoints: [
        {
          tags: tags
          customDnsConfigs: []
          name: '${keyVaultName[i]}${peSuffix}'
          customNetworkInterfaceName: '${keyVaultName[i]}${nicSuffix}'
          ipConfigurations: []
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net' //${environment().suffixes.keyvaultDns}'
              }
            ]
          }
          roleAssignments: []
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
      ]
    }
    dependsOn: [
      modVirtualNetwork
    ]
  }
]

// Storage Account
@description('Deploys a Storage Account.')
module modStorageAccount 'br/public:avm/res/storage/storage-account:0.14.1' = [
  for i in range(0, length(locations)): if (enableStorage) {
    scope: resourceGroup(resourceGroupName_DomainController[i])
    name: 'storageAccountDeployment${i}'
    params: {
      name: storageAccountName[i]
      allowBlobPublicAccess: storageAccount.allowBlobPublicAccess
      enableHierarchicalNamespace: storageAccount.enableHierarchicalNamespace
      enableNfsV3: storageAccount.enableNfsV3
      enableSftp: storageAccount.enableSftp
      largeFileSharesState: storageAccount.largeFileSharesState
      localUsers: storageAccount.localUsers
      location: locations[i]
      lock: {}
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          modUserAssignedIdentity[i].outputs.resourceId
        ]
      }
      managementPolicyRules: storageAccount.managementPolicyRules
      networkAcls: {
        bypass: storageAccount.networkAcls.bypass
        defaultAction: storageAccount.networkAcls.defaultAction
        ipRules: storageAccount.networkAcls.ipRules
      }
      diagnosticSettings: [
        {
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
      blobServices: {
        automaticSnapshotPolicyEnabled: storageAccount.blobServices.automaticSnapshotPolicyEnabled
        containerDeleteRetentionPolicyDays: storageAccount.blobServices.containerDeleteRetentionPolicyDays
        containerDeleteRetentionPolicyEnabled: storageAccount.blobServices.containerDeleteRetentionPolicyEnabled
        containers: storageAccount.blobServices.containers
        deleteRetentionPolicyDays: storageAccount.blobServices.deleteRetentionPolicyDays
        deleteRetentionPolicyEnabled: storageAccount.blobServices.deleteRetentionPolicyEnabled
        diagnosticSettings: [
          {
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            name: 'customSetting'
            workspaceResourceId: modWorkspace[i].outputs.resourceId
          }
        ]
      }
      fileServices: {
        shareDeleteRetentionPolicyDays: storageAccount.fileServices.shareDeleteRetentionPolicyDays
        diagnosticSettings: [
          {
            metricCategories: [
              {
                category: 'AllMetrics'
              }
            ]
            name: 'customSetting'
            workspaceResourceId: modWorkspace[i].outputs.resourceId
          }
        ]
        shares: storageAccount.fileServices.shares
      }
      privateEndpoints: [
        {
          name: '${storageAccountName[i]}${peSuffix}${nameSeparator}blob'
          customNetworkInterfaceName: '${storageAccountName[i]}${nicSuffix}${nameSeparator}blob'
          ipConfigurations: []
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net' //${environment().suffixes.storage}'
              }
            ]
          }
          service: 'blob'
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
        {
          name: '${storageAccountName[i]}${peSuffix}${nameSeparator}file'
          customNetworkInterfaceName: '${storageAccountName[i]}${nicSuffix}${nameSeparator}file'
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net' // ${environment().suffixes.storage}'
              }
            ]
          }
          service: 'file'
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
        }
      ]
      requireInfrastructureEncryption: storageAccount.requireInfrastructureEncryption
      roleAssignments: []
      sasExpirationPeriod: storageAccount.sasExpirationPeriod
      skuName: storageAccount.skuName
      tags: tags
    }
    dependsOn: [
      modVirtualNetwork
    ]
  }
]

// // Availability Set
@description('Deploys an Availability Set for virtual machines.')
module modAvailabilitySet 'br/public:avm/res/compute/availability-set:0.2.0' = [
  for i in range(0, length(locations)): if (enableDomainController) {
    scope: resourceGroup(resourceGroupName_DomainController[i])
    name: 'availabilitySetDeployment${i}'
    params: {
      name: availabilitySetName[i]
      location: locations[i]
      lock: {}
      roleAssignments: []
      tags: tags
      platformFaultDomainCount: availabilitySet.platformFaultDomainCount
      platformUpdateDomainCount: availabilitySet.platformUpdateDomainCount
      proximityPlacementGroupResourceId: availabilitySet.proximityPlacementGroupResourceId
    }
  }
]

// Data Collection Rule
@description('Deploys a Data Collection Rule for monitoring and diagnostics.')
module modDataCollectionRule 'br/public:avm/res/insights/data-collection-rule:0.4.0' = [
  for i in range(0, length(locations)): if (enableDomainController) {
    scope: resourceGroup(resourceGroupName_DomainController[i])
    name: 'dataCollectionRuleDeployment${i}'
    params: {
      dataCollectionRuleProperties: {
        dataFlows: [
          {
            destinations: [
              'azureMonitorMetrics-default'
            ]
            streams: [
              'Microsoft-InsightsMetrics'
            ]
          }
          {
            destinations: [
              operationalInsightsName[i]
            ]
            streams: [
              'Microsoft-Event'
            ]
          }
        ]
        dataSources: {
          performanceCounters: [
            {
              counterSpecifiers: [
                '\\LogicalDisk(_Total)\\% Disk Read Time'
                '\\LogicalDisk(_Total)\\% Disk Time'
                '\\LogicalDisk(_Total)\\% Disk Write Time'
                '\\LogicalDisk(_Total)\\% Free Space'
                '\\LogicalDisk(_Total)\\% Idle Time'
                '\\LogicalDisk(_Total)\\Avg. Disk Queue Length'
                '\\LogicalDisk(_Total)\\Avg. Disk Read Queue Length'
                '\\LogicalDisk(_Total)\\Avg. Disk sec/Read'
                '\\LogicalDisk(_Total)\\Avg. Disk sec/Transfer'
                '\\LogicalDisk(_Total)\\Avg. Disk sec/Write'
                '\\LogicalDisk(_Total)\\Avg. Disk Write Queue Length'
                '\\LogicalDisk(_Total)\\Disk Bytes/sec'
                '\\LogicalDisk(_Total)\\Disk Read Bytes/sec'
                '\\LogicalDisk(_Total)\\Disk Reads/sec'
                '\\LogicalDisk(_Total)\\Disk Transfers/sec'
                '\\LogicalDisk(_Total)\\Disk Write Bytes/sec'
                '\\LogicalDisk(_Total)\\Disk Writes/sec'
                '\\LogicalDisk(_Total)\\Free Megabytes'
                '\\Memory\\% Committed Bytes In Use'
                '\\Memory\\Available Bytes'
                '\\Memory\\Cache Bytes'
                '\\Memory\\Committed Bytes'
                '\\Memory\\Page Faults/sec'
                '\\Memory\\Pages/sec'
                '\\Memory\\Pool Nonpaged Bytes'
                '\\Memory\\Pool Paged Bytes'
                '\\Network Interface(*)\\Bytes Received/sec'
                '\\Network Interface(*)\\Bytes Sent/sec'
                '\\Network Interface(*)\\Bytes Total/sec'
                '\\Network Interface(*)\\Packets Outbound Errors'
                '\\Network Interface(*)\\Packets Received Errors'
                '\\Network Interface(*)\\Packets Received/sec'
                '\\Network Interface(*)\\Packets Sent/sec'
                '\\Network Interface(*)\\Packets/sec'
                '\\Process(_Total)\\Handle Count'
                '\\Process(_Total)\\Thread Count'
                '\\Process(_Total)\\Working Set'
                '\\Process(_Total)\\Working Set - Private'
                '\\Processor Information(_Total)\\% Privileged Time'
                '\\Processor Information(_Total)\\% Processor Time'
                '\\Processor Information(_Total)\\% User Time'
                '\\Processor Information(_Total)\\Processor Frequency'
                '\\System\\Context Switches/sec'
                '\\System\\Processes'
                '\\System\\Processor Queue Length'
                '\\System\\System Up Time'
              ]
              name: 'perfCounterDataSource60'
              samplingFrequencyInSeconds: 60
              streams: [
                'Microsoft-InsightsMetrics'
              ]
            }
          ]
          windowsEventLogs: [
            {
              name: 'eventLogsDataSource'
              streams: [
                'Microsoft-Event'
              ]
              xPathQueries: [
                'Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]'
                'Security!*[System[(band(Keywords,13510798882111488))]]'
                'System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]'
              ]
            }
          ]
        }
        description: 'Collecting Windows-specific performance counters and Windows Event Logs'
        destinations: {
          azureMonitorMetrics: {
            name: 'azureMonitorMetrics-default'
          }
          logAnalytics: [
            {
              name: operationalInsightsName[i]
              workspaceResourceId: modWorkspace[i].outputs.resourceId
            }
          ]
        }
        kind: 'Windows'
      }
      name: dataCollectionRuleName[i]
      location: locations[i]
      tags: tags
    }
    dependsOn: [
      modWorkspace
      modResourceGroupDomainController
    ]
  }
]

@description('References an existing Virtual Network (VNet).')
resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = [
  for i in range(0, length(locations)): if (enableSiteRecovery) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: virtualNetwork[i].name
  }
]

// Recovery Services Vault
@description('Deploys a Recovery Services Vault for backup and disaster recovery.')
module modRecoveryServicesVault 'br/public:avm/res/recovery-services/vault:0.5.1' = [
  for i in range(0, length(locations)): if (enableSiteRecovery) {
    scope: resourceGroup(resourceGroupName_SiteRecovery[i])
    name: 'recoveryServiceVaultDeployment${i}'
    params: {
      name: recoveryServiceVaultName[i]
      backupConfig: {
        enhancedSecurityState: recoveryServicesVault.enhancedSecurityState
        softDeleteFeatureState: recoveryServicesVault.softDeleteFeatureState
      }
      backupPolicies: [
        {
          name: recoveryServicesVault.backupPolicies[0].name
          properties: {
            backupManagementType: recoveryServicesVault.backupPolicies[0].properties.backupManagementType
            instantRPDetails: recoveryServicesVault.backupPolicies[0].properties.instantRPDetails
            instantRpRetentionRangeInDays: recoveryServicesVault.backupPolicies[0].properties.instantRpRetentionRangeInDays
            protectedItemsCount: recoveryServicesVault.backupPolicies[0].properties.protectedItemsCount
            retentionPolicy: {
              dailySchedule: {
                retentionDuration: {
                  count: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.dailySchedule.retentionDuration.count
                  durationType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.dailySchedule.retentionDuration.durationType
                }
                retentionTimes: [
                  recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.dailySchedule.retentionTimes[0]
                ]
              }
              monthlySchedule: {
                retentionDuration: {
                  count: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.monthlySchedule.retentionDuration.count
                  durationType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.monthlySchedule.retentionDuration.durationType
                }
                retentionScheduleFormatType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.monthlySchedule.retentionScheduleFormatType
                retentionScheduleWeekly: {
                  daysOfTheWeek: [
                    recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.monthlySchedule.retentionScheduleWeekly.daysOfTheWeek[0]
                  ]
                  weeksOfTheMonth: [
                    recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.monthlySchedule.retentionScheduleWeekly.weeksOfTheMonth[0]
                  ]
                }
                retentionTimes: [
                  recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.monthlySchedule.retentionTimes[0]
                ]
              }
              retentionPolicyType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.retentionPolicyType
              weeklySchedule: {
                daysOfTheWeek: [
                  recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.weeklySchedule.daysOfTheWeek[0]
                ]
                retentionDuration: {
                  count: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.weeklySchedule.retentionDuration.count
                  durationType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.weeklySchedule.retentionDuration.durationType
                }
                retentionTimes: [
                  recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.weeklySchedule.retentionTimes[0]
                ]
              }
              yearlySchedule: {
                monthsOfYear: [
                  recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.monthsOfYear[0]
                ]
                retentionDuration: {
                  count: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.retentionDuration.count
                  durationType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.retentionDuration.durationType
                }
                retentionScheduleFormatType: recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.retentionScheduleFormatType
                retentionScheduleWeekly: {
                  daysOfTheWeek: [
                    recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.retentionScheduleWeekly.daysOfTheWeek[0]
                  ]
                  weeksOfTheMonth: [
                    recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.retentionScheduleWeekly.weeksOfTheMonth[0]
                  ]
                }
                retentionTimes: [
                  recoveryServicesVault.backupPolicies[0].properties.retentionPolicy.yearlySchedule.retentionTimes[0]
                ]
              }
            }
            schedulePolicy: {
              schedulePolicyType: recoveryServicesVault.backupPolicies[0].properties.schedulePolicy.schedulePolicyType
              scheduleRunFrequency: recoveryServicesVault.backupPolicies[0].properties.schedulePolicy.scheduleRunFrequency
              scheduleRunTimes: [
                recoveryServicesVault.backupPolicies[0].properties.schedulePolicy.scheduleRunTimes[0]
              ]
              scheduleWeeklyFrequency: recoveryServicesVault.backupPolicies[0].properties.schedulePolicy.scheduleWeeklyFrequency
            }
            timeZone: recoveryServicesVault.backupPolicies[0].properties.timeZone
          }
        }
        {
          name: recoveryServicesVault.backupPolicies[1].name
          properties: {
            backupManagementType: recoveryServicesVault.backupPolicies[1].properties.backupManagementType
            protectedItemsCount: recoveryServiceVaultName[i].backupPolicies[1].properties.protectedItemsCount
            settings: {
              isCompression: recoveryServicesVault.backupPolicies[1].properties.settings.isCompression
              issqlcompression: recoveryServicesVault.backupPolicies[1].properties.settings.issqlcompression
              timeZone: recoveryServicesVault.backupPolicies[1].properties.settings.timeZone
            }
            subProtectionPolicy: [
              {
                policyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].policyType
                retentionPolicy: {
                  monthlySchedule: {
                    retentionDuration: {
                      count: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.monthlySchedule.retentionDuration.count
                      durationType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.monthlySchedule.retentionDuration.durationType
                    }
                    retentionScheduleFormatType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.monthlySchedule.retentionScheduleFormatType
                    retentionScheduleWeekly: {
                      daysOfTheWeek: [
                        recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.monthlySchedule.retentionScheduleWeekly.daysOfTheWeek[0]
                      ]
                      weeksOfTheMonth: [
                        recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.monthlySchedule.retentionScheduleWeekly.weeksOfTheMonth[0]
                      ]
                    }
                    retentionTimes: [
                      recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.monthlySchedule.retentionTimes[0]
                    ]
                  }
                  retentionPolicyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.retentionPolicyType
                  weeklySchedule: {
                    daysOfTheWeek: [
                      recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.weeklySchedule.daysOfTheWeek[0]
                    ]
                    retentionDuration: {
                      count: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.weeklySchedule.retentionDuration.count
                      durationType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.weeklySchedule.retentionDuration.durationType
                    }
                    retentionTimes: [
                      recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.weeklySchedule.retentionTimes[0]
                    ]
                  }
                  yearlySchedule: {
                    monthsOfYear: [
                      recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.monthsOfYear[0]
                    ]
                    retentionDuration: {
                      count: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.retentionDuration.count
                      durationType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.retentionDuration.durationType
                    }
                    retentionScheduleFormatType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.retentionScheduleFormatType
                    retentionScheduleWeekly: {
                      daysOfTheWeek: [
                        recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.retentionScheduleWeekly.daysOfTheWeek[0]
                      ]
                      weeksOfTheMonth: [
                        recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.retentionScheduleWeekly.weeksOfTheMonth[0]
                      ]
                    }
                    retentionTimes: [
                      recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].retentionPolicy.yearlySchedule.retentionTimes[0]
                    ]
                  }
                }
                schedulePolicy: {
                  schedulePolicyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].schedulePolicy.schedulePolicyType
                  scheduleRunDays: [
                    recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].schedulePolicy.scheduleRunDays[0]
                  ]
                  scheduleRunFrequency: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].schedulePolicy.scheduleRunFrequency
                  scheduleRunTimes: [
                    recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].schedulePolicy.scheduleRunTimes[0]
                  ]
                  scheduleWeeklyFrequency: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[0].schedulePolicy.scheduleWeeklyFrequency
                }
              }
              {
                policyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].policyType
                retentionPolicy: {
                  retentionDuration: {
                    count: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].retentionPolicy.retentionDuration.count
                    durationType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].retentionPolicy.retentionDuration.durationType
                  }
                  retentionPolicyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].retentionPolicy.retentionPolicyType
                }
                schedulePolicy: {
                  schedulePolicyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].schedulePolicy.schedulePolicyType
                  scheduleRunDays: [
                    recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].schedulePolicy.scheduleRunDays[0]
                  ]
                  scheduleRunFrequency: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].schedulePolicy.scheduleRunFrequency
                  scheduleRunTimes: [
                    recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].schedulePolicy.scheduleRunTimes[0]
                  ]
                  scheduleWeeklyFrequency: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[1].schedulePolicy.scheduleWeeklyFrequency
                }
              }
              {
                policyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[2].policyType
                retentionPolicy: {
                  retentionDuration: {
                    count: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[2].retentionPolicy.retentionDuration.count
                    durationType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[2].retentionPolicy.retentionDuration.durationType
                  }
                  retentionPolicyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[2].retentionPolicy.retentionPolicyType
                }
                schedulePolicy: {
                  scheduleFrequencyInMins: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[2].schedulePolicy.scheduleFrequencyInMins
                  schedulePolicyType: recoveryServicesVault.backupPolicies[1].properties.subProtectionPolicy[2].schedulePolicy.schedulePolicyType
                }
              }
            ]
            workLoadType: recoveryServicesVault.backupPolicies[1].properties.workLoadType
          }
        }
        {
          name: recoveryServicesVault.backupPolicies[2].name
          properties: {
            backupManagementType: recoveryServicesVault.backupPolicies[2].properties.backupManagementType
            protectedItemsCount: recoveryServicesVault.backupPolicies[2].properties.protectedItemsCount
            retentionPolicy: {
              dailySchedule: {
                retentionDuration: {
                  count: recoveryServicesVault.backupPolicies[2].properties.retentionPolicy.dailySchedule.retentionDuration.count
                  durationType: recoveryServicesVault.backupPolicies[2].properties.retentionPolicy.dailySchedule.retentionDuration.durationType
                }
                retentionTimes: [
                  recoveryServicesVault.backupPolicies[2].properties.retentionPolicy.dailySchedule.retentionTimes[0]
                ]
              }
              retentionPolicyType: recoveryServicesVault.backupPolicies[2].properties.retentionPolicy.retentionPolicyType
            }
            schedulePolicy: {
              schedulePolicyType: recoveryServicesVault.backupPolicies[2].properties.schedulePolicy.schedulePolicyType
              scheduleRunFrequency: recoveryServicesVault.backupPolicies[2].properties.schedulePolicy.scheduleRunFrequency
              scheduleRunTimes: [
                recoveryServicesVault.backupPolicies[2].properties.schedulePolicy.scheduleRunTimes[0]
              ]
              scheduleWeeklyFrequency: recoveryServicesVault.backupPolicies[2].properties.schedulePolicy.scheduleWeeklyFrequency
            }
            timeZone: recoveryServicesVault.backupPolicies[2].properties.timeZone
            workloadType: recoveryServicesVault.backupPolicies[2].properties.workloadType
          }
        }
      ]
      backupStorageConfig: {
        crossRegionRestoreFlag: recoveryServicesVault.backupStorageConfig.crossRegionRestoreFlag
        storageModelType: recoveryServicesVault.backupStorageConfig.storageModelType
      }
      diagnosticSettings: [
        {
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          storageAccountResourceId: modStorageAccount[i].outputs.resourceId
          workspaceResourceId: modWorkspace[i].outputs.resourceId
        }
      ]
      location: locations[i]
      lock: {}
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          modUserAssignedIdentity[i].outputs.resourceId
        ]
      }
      monitoringSettings: {
        azureMonitorAlertSettings: {
          alertsForAllJobFailures: 'Enabled'
        }
        classicAlertSettings: {
          alertsForCriticalOperations: 'Enabled'
        }
      }
      privateEndpoints: [
        {
          name: '${recoveryServiceVaultName[i]}${peSuffix}'
          customNetworkInterfaceName: '${recoveryServiceVaultName[i]}${nicSuffix}'
          ipConfigurations: [
            {
              name: 'ipConfig-1'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-tel1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefix, 20)
              }
            }
            {
              name: 'ipConfig-2'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-prot2'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefix, 21)
              }
            }
            {
              name: 'ipConfig-3'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-srs1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefix, 22)
              }
            }
            {
              name: 'ipConfig-4'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-rcm1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefix, 23)
              }
            }
            {
              name: 'ipConfig-5'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-id1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefix, 24)
              }
            }
          ]
          privateDnsZoneGroup: {
            name: 'privateDnsZoneGroup'
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.siterecovery.windowsazure.com' // .${locationsShort[i]}.backup.windowsazure.com'
              }
            ]
          }
          subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
          tags: tags
        }
      ]
      replicationAlertSettings: {
        customEmailAddresses: [
          'john.kaufman@neudesic.com'
        ]
        locale: 'en-US'
        sendToOwners: 'Send'
      }
      roleAssignments: []
      securitySettings: {
        immutabilitySettings: {
          state: 'Unlocked'
        }
      }
      tags: tags
    }
    dependsOn: [
      modStorageAccount
      modUserAssignedIdentity
      modVirtualNetwork
    ]
  }
]

// Windows Virtual Machine

module modVirtualMachine_Windows 'br/public:avm/res/compute/virtual-machine:0.8.0' = [
  for i in range(0, length(locations)): if (enableDomainController) {
    scope: resourceGroup(resourceGroupName_DomainController[i])
    name: 'virtualMachineDeploymentWindows${i}'
    params: {
      name: virtualMachineName_Windows[i].azureName
      computerName: virtualMachineName_Windows[i].adName
      adminUsername: virtualMachine_Windows.adminUsername
      adminPassword: 'ThievingCat10!'
      backupPolicyName: virtualMachine_Windows.backupPolicyName
      backupVaultName: recoveryServiceVaultName[i]
      backupVaultResourceGroup: modResourceGroupSiteRecovery[i].outputs.name
      enableAutomaticUpdates: virtualMachine_Windows.enableAutomaticUpdates
      encryptionAtHost: virtualMachine_Windows.encryptionAtHost
      osType: virtualMachine_Windows.osType
      vmSize: virtualMachine_Windows.vmSize
      zone: virtualMachine_Windows.zone
      imageReference: virtualMachine_Windows.imageReference
      nicConfigurations: [
        {
          deleteOption: virtualMachine_Windows.nicConfigurations.deleteOption
          diagnosticSettings: [
            {
              metricCategories: [
                {
                  category: 'AllMetrics'
                }
              ]
              name: virtualMachine_Windows.nicConfigurations.name
              storageAccountResourceId: modStorageAccount[i].outputs.resourceId
              workspaceResourceId: modWorkspace[i].outputs.resourceId
            }
          ]
          enableIPForwarding: virtualMachine_Windows.nicConfigurations.enableIPForwarding
          ipConfigurations: [
            {
              name: 'ipConfig01'
              subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
              privateIpAddressVersion: virtualMachine_Windows.nicConfigurations.privateIpAddressVersion
              privateIPAllocationMethod: virtualMachine_Windows.nicConfigurations.privateIPAllocationMethod
            }
          ]
          name: '${virtualMachineName_Windows[i].azureName}${nicSuffix}'
          roleAssignments: []
        }
      ]
      osDisk: {
        caching: virtualMachine_Windows.osDisk.caching
        createOption: virtualMachine_Windows.osDisk.createOption
        deleteOption: virtualMachine_Windows.osDisk.deleteOption
        diskSizeGB: virtualMachine_Windows.osDisk.diskSizeGB
        managedDisk: {
          storageAccountType: virtualMachine_Windows.osDisk.managedDisk.storageAccountType
        }
        name: '${virtualMachineName_Windows[i].azureName}${nameSeparator}osdisk01'
      }
      dataDisks: [
        {
          caching: virtualMachine_Windows.dataDisks.caching
          createOption: virtualMachine_Windows.dataDisks.createOption
          deleteOption: virtualMachine_Windows.dataDisks.deleteOption
          diskSizeGB: virtualMachine_Windows.dataDisks.diskSizeGB
          lun: virtualMachine_Windows.dataDisks.lun
          managedDisk: {
            storageAccountType: virtualMachine_Windows.dataDisks.managedDisk.storageAccountType
          }
          name: '${virtualMachineName_Windows[i].azureName}${nameSeparator}datadisk01'
        }
      ]
      autoShutdownConfig: {
        dailyRecurrenceTime: virtualMachine_Windows.autoShutdownConfig.dailyRecurrenceTime
        notificationEmail: virtualMachine_Windows.autoShutdownConfig.notificationEmail
        notificationLocale: virtualMachine_Windows.autoShutdownConfig.notificationLocale
        notificationStatus: virtualMachine_Windows.autoShutdownConfig.notificationStatus
        notificationTimeInMinutes: virtualMachine_Windows.autoShutdownConfig.notificationTimeInMinutes
        status: virtualMachine_Windows.autoShutdownConfig.status
        timeZone: virtualMachine_Windows.autoShutdownConfig.timeZone
      }
      extensionAadJoinConfig: {
        enabled: virtualMachine_Windows.extensionAadJoinConfig.enabled
        tags: tags
      }
      extensionAntiMalwareConfig: {
        enabled: virtualMachine_Windows.extensionAntiMalwareConfig.enabled
        settings: {
          AntimalwareEnabled: virtualMachine_Windows.extensionAntiMalwareConfig.settings.AntimalwareEnabled
          Exclusions: {
            Extensions: virtualMachine_Windows.extensionAntiMalwareConfig.settings.Exclusions.Extensions
            Paths: virtualMachine_Windows.extensionAntiMalwareConfig.settings.Exclusions.Paths
            Processes: virtualMachine_Windows.extensionAntiMalwareConfig.settings.Exclusions.Processes
          }
          RealtimeProtectionEnabled: virtualMachine_Windows.extensionAntiMalwareConfig.settings.RealtimeProtectionEnabled
          ScheduledScanSettings: {
            day: virtualMachine_Windows.extensionAntiMalwareConfig.settings.ScheduledScanSettings.day
            isEnabled: virtualMachine_Windows.extensionAntiMalwareConfig.settings.ScheduledScanSettings.isEnabled
            scanType: virtualMachine_Windows.extensionAntiMalwareConfig.settings.ScheduledScanSettings.scanType
            time: virtualMachine_Windows.extensionAntiMalwareConfig.settings.ScheduledScanSettings.time
          }
        }
        tags: tags
      }
      extensionDependencyAgentConfig: {
        enableAMA: virtualMachine_Windows.extensionDependencyAgentConfig.enableAMA
        enabled: virtualMachine_Windows.extensionDependencyAgentConfig.enabled
        tags: tags
      }
      extensionDSCConfig: {
        enabled: virtualMachine_Windows.extensionDSCConfig.enabled
        tags: tags
      }
      extensionMonitoringAgentConfig: {
        dataCollectionRuleAssociations: [
          {
            dataCollectionRuleResourceId: modDataCollectionRule[i].outputs.resourceId
            name: 'SendMetricsToLAW'
          }
        ]
        enabled: true
        tags: tags
      }
      extensionNetworkWatcherAgentConfig: {
        enabled: true
        tags: tags
      }
      location: locations[i]
      lock: {}
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          modUserAssignedIdentity[i].outputs.resourceId
        ]
      }
      patchMode: virtualMachine_Windows.patchMode
      proximityPlacementGroupResourceId: virtualMachine_Windows.proximityPlacementGroupResourceId
      rebootSetting: virtualMachine_Windows.rebootSetting
      roleAssignments: []
      tags: {}
    }
    dependsOn: [
      modDataCollectionRule
      modRecoveryServicesVault
      modUserAssignedIdentity
      modStorageAccount
      modVirtualNetwork
      modWorkspace
      modKeyVault
    ]
  }
]
