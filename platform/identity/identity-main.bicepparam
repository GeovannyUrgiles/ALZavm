using 'identity-main.bicep'

// IaC Version Number

var version = 'v1.0.0'

//-// Deployment Options

// Virtual Network
param enableNetwork = true
param enableNetworkSecurityGroups = true

// Supporting Resources
param enableIdentity = true
param enableMonitoring = true
param enableKeyVault = true
param enableStorage = true
param enableSiteRecovery = true
param enableDomainController = true

param dnsServers = [
  '168.63.129.16'
]

// Subscription(s)

param subscriptionId = '5a718e73-cce6-49e2-af77-023ea133c332' // Current Subscription ID (Identity)
param conSubscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// Paired Regions

param locations = [
  'centralus' // Primary Region
  'eastus2' // Secondary Region
]
param locationsShort = [
  'cus' // Primary Region
  'eus2' // Secondary Region
]

// Resource Group Names

param resourceGroupName_Network = [
  'idncusnetworkrg'
  'idneus2networkrg'
]
param resourceGroupName_SiteRecovery = [
  'idncussiterecoveryrg'
  'idneus2siterecoveryrg'
]
param resourceGroupName_DomainController = [
  'idncusdomaincontrollerrg'
  'idneus2domaincontrollerrg'
]
param resourceGroupName_Identity = [
  'idncusidentityrg'
  'idneus2identityrg'
]
// Resource Group Names (Private DNS)

param resourceGroupName_PrivateDns = 'concusdnsrg'

// Virtual Network Names

var virtualNetworkNamePrimary = 'idncusvnet'
var virtualNetworkNameSecondary = 'idneus2vnet'

// Virtual Machine Names

param virtualMachineName_Windows = [
  {
    azureName: 'idncusdcvm01'
    adName: 'dc01'
  }
  {
    azureName: 'idneus2dcvm01'
    adName: 'dc02'
  }
]

// Virtual Network Property Array

param virtualNetwork = [
  {
    name: virtualNetworkNamePrimary // Primary Virtual Network Name
    addressPrefixes: [
      '10.3.0.0/18' // Primary Address Prefix
    ]
    subnets: [subnets0]
  }
  {
    name: virtualNetworkNameSecondary // Secondary Virtual Network Name
    addressPrefixes: [
      '10.4.0.0/18' // Secondary Address Prefix
    ]
    subnets: [subnets1]
  }
]

// Resource Name Arrays

param operationalInsightsName = [
  'idncusoiw'
  'idneus2oiw'
]
param uamiName = [
  'idncusmi'
  'idneus2mi'
]
param keyVaultName = [
  'idncuskv01'
  'idneus2kv01'
]
param storageAccountName = [
  'idncusdiagsa01'
  'idneus2diagsa01'
]
param dataCollectionRuleName = [
  'idncusdcr01'
  'idneus2dcr01'
]
param recoveryServiceVaultName = [
  'idncusrsv01'
  'idneus2rsv01'
]
// Key Vault Properties

param keyVault = {
  sku: 'standard'
  accessPolicies: []
  publicNetworkAccess: 'Disabled'
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
  enablePurgeProtection: false
  softDeleteRetentionInDays: 7
  enableRbacAuthorization: true
}

// Resource Suffixes

param nameSeparator = '-'
param nsgSuffix = '${nameSeparator}nsg'
param peSuffix = '${nameSeparator}pe'
param nicSuffix = '${nameSeparator}nic'

// Default Tags

param tags = {
  Environment: 'Non-Prod'
  'hidden-title': version
  Role: 'DeploymentValidation'
}

// Resource Group Lock properties

param lock = {
  delete: {
    name: 'Do Not Delete'
    kind: 'CanNotDelete'
  }
  readonly: {
    name: 'Read Only'
    kind: 'ReadOnly'
  }
}

// Virtual Network Subnets

param subnets0 = [
  // Primary Region Virtual Network Subnets
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}virtualmachinesn'
    addressPrefix: '10.3.0.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}virtualmachinesn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn'
    addressPrefix: '10.3.1.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn${nsgSuffix}'
    serviceEndpoints: []
  }
]

param subnets1 = [
  // Secondary Region Virtual Network Subnets
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}virtualmachinesn'
    addressPrefix: '10.4.0.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[1]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}virtualmachinesn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn'
    addressPrefix: '10.4.1.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[1]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn${nsgSuffix}'
    serviceEndpoints: []
  }
]

// Network Security Group Properties

param securityRulesDefault = []

// Role Assignments for Resource Groups

param roleAssignmentsNetwork = [
  // {
  //   // Network Team
  //   name: '3566ddd3-870d-4618-bd22-3d50915a21ef'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'Owner'
  // }
  // {
  //   // Security Team
  //   name: '<name>'
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  // }
  // {
  //   // Neudesic Engineering
  //   principalId: '<principalId>'
  //   principalType: 'ServicePrincipal'
  //   roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  // }
]

// Availability Set Properties

param availabilitySetName = [
  'idncusavset'
  'idneus2avset'
]

param availabilitySet = {
  proximityPlacementGroupResourceId: ''
  platformFaultDomainCount: 2
  platformUpdateDomainCount: 5
}

// Virtual Machine Properties (Windows)

param virtualMachine_Windows = {
  adminUsername: 'vmadmin'
  enableAutomaticUpdates: true
  encryptionAtHost: false
  osType: 'Windows'
  backupPolicyName: 'VMpolicy'
  vmSize: 'Standard_DS1_v2'
  zone: 2
  imageReference: {
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    sku: '2019-datacenter'
    version: 'latest'
  }
  extensionAadJoinConfig: {
    enabled: true
  }
  nicConfigurations: {
    deleteOption: 'Delete'
    name: 'customSetting'
    enableIPForwarding: true
    privateIpAddressVersion: 'IPv4'
    privateIPAllocationMethod: 'Dynamic'
  }
  osDisk: {
    caching: 'ReadWrite'
    createOption: 'FromImage'
    deleteOption: 'Delete'
    diskSizeGB: 128
    managedDisk: {
      storageAccountType: 'Standard_LRS'
    }
  }
  dataDisks: {
    caching: 'None'
    createOption: 'Empty'
    deleteOption: 'Delete'
    diskSizeGB: 128
    lun: 0
    managedDisk: {
      storageAccountType: 'Standard_LRS'
    }
  }
  autoShutdownConfig: {
    dailyRecurrenceTime: '17:00'
    notificationEmail: 'john.kaufman@neudesic.com'
    notificationLocale: 'en'
    notificationStatus: 'Enabled'
    notificationTimeInMinutes: 30
    status: 'Enabled'
    timeZone: 'Central Standard Time'
  }
  enableAutoUpdate: true
  patchMode: 'AutomaticByPlatform'
  rebootSetting: 'IfRequired'
  proximityPlacementGroupResourceId: ''
  enableBackup: true
  enableMonitoring: true
  enableUpdateManagement: true
  enableTelemetry: true
  extensionAntiMalwareConfig: {
    enabled: true
    settings: {
      AntimalwareEnabled: true
      Exclusions: {
        Extensions: '' //  to exclude, example: '.ext1;.ext2'
        Paths: '' // to exclude, example: 'c:\\excluded-path-1;c:\\excluded-path-2'
        Processes: '' // to exclude, example: 'excludedproc1.exe;excludedproc2.exe'
      }
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        day: '7'
        isEnabled: true
        scanType: 'Quick'
        time: '120'
      }
    }
  }
  extensionDependencyAgentConfig: {
    enableAMA: true
    enabled: true
    tags: tags
  }
  extensionDSCConfig: {
    enabled: true
    tags: tags
  }
}

// Storage Account Properties (Diagnostics)

param storageAccount = {
  accountTier: 'Standard'
  requireInfrastructureEncryption: true
  sasExpirationPeriod: '180.00:00:00'
  skuName: 'Standard_LRS'
  accountReplicationType: 'LRS'
  accountKind: 'StorageV2'
  accountAccessTier: 'Hot'
  allowBlobPublicAccess: false
  blobServices: {
    automaticSnapshotPolicyEnabled: true
    containerDeleteRetentionPolicyDays: 10
    containerDeleteRetentionPolicyEnabled: true
    containers: []
    deleteRetentionPolicyDays: 9
    deleteRetentionPolicyEnabled: true
  }
  enableHierarchicalNamespace: false
  enableNfsV3: false
  enableSftp: false
  fileServices: {
    shareDeleteRetentionPolicyDays: 10
    shares: []
  }
  largeFileSharesState: 'Enabled'
  localUsers: []
  managementPolicyRules: []
  networkAcls: {
    bypass: 'AzureServices'
    defaultAction: 'Deny'
    ipRules: []
  }
}


param recoveryServicesVault = {
  backupConfig: {
        enhancedSecurityState: 'Disabled'
        softDeleteFeatureState: 'Disabled'
      }
      backupPolicies: [
        {
          name: 'VMpolicy'
          properties: {
            backupManagementType: 'AzureIaasVM'
            instantRPDetails: {}
            instantRpRetentionRangeInDays: 2
            protectedItemsCount: 0
            retentionPolicy: {
              dailySchedule: {
                retentionDuration: {
                  count: 180
                  durationType: 'Days'
                }
                retentionTimes: [
                  '2019-11-07T07:00:00Z'
                ]
              }
              monthlySchedule: {
                retentionDuration: {
                  count: 60
                  durationType: 'Months'
                }
                retentionScheduleFormatType: 'Weekly'
                retentionScheduleWeekly: {
                  daysOfTheWeek: [
                    'Sunday'
                  ]
                  weeksOfTheMonth: [
                    'First'
                  ]
                }
                retentionTimes: [
                  '2019-11-07T07:00:00Z'
                ]
              }
              retentionPolicyType: 'LongTermRetentionPolicy'
              weeklySchedule: {
                daysOfTheWeek: [
                  'Sunday'
                ]
                retentionDuration: {
                  count: 12
                  durationType: 'Weeks'
                }
                retentionTimes: [
                  '2019-11-07T07:00:00Z'
                ]
              }
              yearlySchedule: {
                monthsOfYear: [
                  'January'
                ]
                retentionDuration: {
                  count: 10
                  durationType: 'Years'
                }
                retentionScheduleFormatType: 'Weekly'
                retentionScheduleWeekly: {
                  daysOfTheWeek: [
                    'Sunday'
                  ]
                  weeksOfTheMonth: [
                    'First'
                  ]
                }
                retentionTimes: [
                  '2019-11-07T07:00:00Z'
                ]
              }
            }
            schedulePolicy: {
              schedulePolicyType: 'SimpleSchedulePolicy'
              scheduleRunFrequency: 'Daily'
              scheduleRunTimes: [
                '2019-11-07T07:00:00Z'
              ]
              scheduleWeeklyFrequency: 0
            }
            timeZone: 'UTC'
          }
        }
        {
          name: 'sqlpolicy'
          properties: {
            backupManagementType: 'AzureWorkload'
            protectedItemsCount: 0
            settings: {
              isCompression: true
              issqlcompression: true
              timeZone: 'UTC'
            }
            subProtectionPolicy: [
              {
                policyType: 'Full'
                retentionPolicy: {
                  monthlySchedule: {
                    retentionDuration: {
                      count: 60
                      durationType: 'Months'
                    }
                    retentionScheduleFormatType: 'Weekly'
                    retentionScheduleWeekly: {
                      daysOfTheWeek: [
                        'Sunday'
                      ]
                      weeksOfTheMonth: [
                        'First'
                      ]
                    }
                    retentionTimes: [
                      '2019-11-07T22:00:00Z'
                    ]
                  }
                  retentionPolicyType: 'LongTermRetentionPolicy'
                  weeklySchedule: {
                    daysOfTheWeek: [
                      'Sunday'
                    ]
                    retentionDuration: {
                      count: 104
                      durationType: 'Weeks'
                    }
                    retentionTimes: [
                      '2019-11-07T22:00:00Z'
                    ]
                  }
                  yearlySchedule: {
                    monthsOfYear: [
                      'January'
                    ]
                    retentionDuration: {
                      count: 10
                      durationType: 'Years'
                    }
                    retentionScheduleFormatType: 'Weekly'
                    retentionScheduleWeekly: {
                      daysOfTheWeek: [
                        'Sunday'
                      ]
                      weeksOfTheMonth: [
                        'First'
                      ]
                    }
                    retentionTimes: [
                      '2019-11-07T22:00:00Z'
                    ]
                  }
                }
                schedulePolicy: {
                  schedulePolicyType: 'SimpleSchedulePolicy'
                  scheduleRunDays: [
                    'Sunday'
                  ]
                  scheduleRunFrequency: 'Weekly'
                  scheduleRunTimes: [
                    '2019-11-07T22:00:00Z'
                  ]
                  scheduleWeeklyFrequency: 0
                }
              }
              {
                policyType: 'Differential'
                retentionPolicy: {
                  retentionDuration: {
                    count: 30
                    durationType: 'Days'
                  }
                  retentionPolicyType: 'SimpleRetentionPolicy'
                }
                schedulePolicy: {
                  schedulePolicyType: 'SimpleSchedulePolicy'
                  scheduleRunDays: [
                    'Monday'
                  ]
                  scheduleRunFrequency: 'Weekly'
                  scheduleRunTimes: [
                    '2017-03-07T02:00:00Z'
                  ]
                  scheduleWeeklyFrequency: 0
                }
              }
              {
                policyType: 'Log'
                retentionPolicy: {
                  retentionDuration: {
                    count: 15
                    durationType: 'Days'
                  }
                  retentionPolicyType: 'SimpleRetentionPolicy'
                }
                schedulePolicy: {
                  scheduleFrequencyInMins: 120
                  schedulePolicyType: 'LogSchedulePolicy'
                }
              }
            ]
            workLoadType: 'SQLDataBase'
          }
        }
        {
          name: 'filesharepolicy'
          properties: {
            backupManagementType: 'AzureStorage'
            protectedItemsCount: 0
            retentionPolicy: {
              dailySchedule: {
                retentionDuration: {
                  count: 30
                  durationType: 'Days'
                }
                retentionTimes: [
                  '2019-11-07T04:30:00Z'
                ]
              }
              retentionPolicyType: 'LongTermRetentionPolicy'
            }
            schedulePolicy: {
              schedulePolicyType: 'SimpleSchedulePolicy'
              scheduleRunFrequency: 'Daily'
              scheduleRunTimes: [
                '2019-11-07T04:30:00Z'
              ]
              scheduleWeeklyFrequency: 0
            }
            timeZone: 'UTC'
            workloadType: 'AzureFileShare'
          }
        }
      ]
      backupStorageConfig: {
        crossRegionRestoreFlag: true
        storageModelType: 'GeoRedundant'
      }
      monitoringSettings: {
        azureMonitorAlertSettings: {
          alertsForAllJobFailures: 'Enabled'
        }
        classicAlertSettings: {
          alertsForCriticalOperations: 'Enabled'
        }
      }
    }
  
