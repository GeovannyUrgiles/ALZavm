targetScope = 'subscription'

// Deployment Boolean Parameters

param enableUserAssignedManagedIdentity bool
param enableNetworkSecurityGroups bool
param enableVirtualNetwork bool
param enableOperationalInsights bool
param enableKeyVault bool
param enableStorageAccount bool
param enableRecoveryServiceVault bool
param enableVirtualMachine bool

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

param keyVault object
param storageAccount object
param availabilitySet object
param virtualMachine_Windows object

// Resource Suffixes

param nsgSuffix string
param peSuffix string
param nicSuffix string

// Resource Group Parameters

param resourceGroupName_Network array

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

module modResourceGroupNetwork 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
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

module modUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = [
  for i in range(0, length(locations)): if (enableUserAssignedManagedIdentity) {
    scope: resourceGroup(resourceGroupName_Network[i])
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

// Operational Insights Workspace
module modWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = [
  for i in range(0, length(locations)): if (enableOperationalInsights) {
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

module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
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

module modKeyVault 'br/public:avm/res/key-vault/vault:0.9.0' = [
  for i in range(0, length(locations)): if (enableKeyVault) {
    scope: resourceGroup(resourceGroupName_Network[i])
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

module modStorageAccount 'br/public:avm/res/storage/storage-account:0.14.1' = [
  for i in range(0, length(locations)): if (enableStorageAccount) {
    scope: resourceGroup(resourceGroupName_Network[i])
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

module modAvailabilitySet 'br/public:avm/res/compute/availability-set:0.2.0' = [
  for i in range(0, length(locations)): if (enableVirtualMachine) {
    scope: resourceGroup(resourceGroupName_Network[i])
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
module modDataCollectionRule 'br/public:avm/res/insights/data-collection-rule:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualMachine) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'dataCollectionRuleDeployment'
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
  }
]

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = [
  for i in range(0, length(locations)): if (enableRecoveryServiceVault) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: virtualNetwork[i].name
  }
]

// Recovery Services Vault

module modRecoverServicesVault 'br/public:avm/res/recovery-services/vault:0.5.1' = [
  for i in range(0, length(locations)): if (enableRecoveryServiceVault) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'recoveryServiceVaultDeployment${i}'
    params: {
      name: recoveryServiceVaultName[i]
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
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefixes[0], 20)
              }
            }
            {
              name: 'ipConfig-2'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-prot2'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefixes[0], 21)
              }
            }
            {
              name: 'ipConfig-3'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-srs1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefixes[0], 22)
              }
            }
            {
              name: 'ipConfig-4'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-rcm1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefixes[0], 23)
              }
            }
            {
              name: 'ipConfig-5'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-id1'
                privateIPAddress: cidrHost(vnet[i].properties.subnets[1].properties.addressPrefixes[0], 24)
              }
            }
          ]
          privateDnsZoneGroup: {
            name: 'privateDnsZoneGroup'
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.cus.backup.windowsazure.com' // .${locationsShort[i]}.backup.windowsazure.com'
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
  for i in range(0, length(locations)): if (enableVirtualMachine) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'virtualMachineDeploymentWindows${i}'
    params: {
      name: virtualMachineName_Windows[i]
      computerName: 'winvm1'
      adminUsername: 'vmadmin'
      adminPassword: 'ThievingCat10!'
      backupPolicyName: 'VMpolicy'
      backupVaultName: recoveryServiceVaultName[i]
      backupVaultResourceGroup: modResourceGroupNetwork[i].outputs.name
      enableAutomaticUpdates: true
      encryptionAtHost: false
      osType: 'Windows'
      vmSize: virtualMachine_Windows.vmSize
      zone: 2
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2019-datacenter'
        version: 'latest'
      }
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
              name: 'ipconfig01'
              subnetResourceId: modVirtualNetwork[i].outputs.subnetResourceIds[1]
              privateIpAddressVersion: virtualMachine_Windows.nicConfigurations.privateIpAddressVersion
              privateIPAllocationMethod: virtualMachine_Windows.nicConfigurations.privateIPAllocationMethod
            }
          ]
          name: '${virtualMachineName_Windows[i]}${nicSuffix}'
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
        name: '${virtualMachineName_Windows[i]}${nameSeparator}osdisk01'
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
          name: '${virtualMachineName_Windows[i]}${nameSeparator}datadisk01'
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
      modRecoverServicesVault
      modStorageAccount
      modVirtualNetwork
    ]
  }
]
