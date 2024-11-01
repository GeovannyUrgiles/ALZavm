param vaults_ThievingVault_name string = 'ThievingVault'
param privateEndpoints_sfghsrghsrth_externalid string = '/subscriptions/5a718e73-cce6-49e2-af77-023ea133c332/resourceGroups/idnwus2networkrg/providers/Microsoft.Network/privateEndpoints/sfghsrghsrth'

resource vaults_ThievingVault_name_resource 'Microsoft.RecoveryServices/vaults@2024-04-30-preview' = {
  name: vaults_ThievingVault_name
  location: 'centralus'
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {
    securitySettings: {
      softDeleteSettings: {
        softDeleteRetentionPeriodInDays: 0
        softDeleteState: 'Enabled'
        enhancedSecurityState: 'Enabled'
      }
    }
    redundancySettings: {
      standardTierStorageRedundancy: 'GeoRedundant'
      crossRegionRestore: 'Disabled'
    }
    publicNetworkAccess: 'Disabled'
    restoreSettings: {
      crossSubscriptionRestoreSettings: {
        crossSubscriptionRestoreState: 'Enabled'
      }
    }
  }
}

resource vaults_ThievingVault_name_DefaultPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-04-30-preview' = {
  parent: vaults_ThievingVault_name_resource
  name: 'DefaultPolicy'
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRPDetails: {}
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '2024-10-31T07:30:00Z'
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '2024-10-31T07:30:00Z'
        ]
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: 'UTC'
    protectedItemsCount: 0
  }
}

resource vaults_ThievingVault_name_EnhancedPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-04-30-preview' = {
  parent: vaults_ThievingVault_name_resource
  name: 'EnhancedPolicy'
  properties: {
    backupManagementType: 'AzureIaasVM'
    policyType: 'V2'
    instantRPDetails: {}
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicyV2'
      scheduleRunFrequency: 'Hourly'
      hourlySchedule: {
        interval: 4
        scheduleWindowStartTime: '2024-10-31T08:00:00Z'
        scheduleWindowDuration: 12
      }
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      dailySchedule: {
        retentionTimes: [
          '2024-10-31T08:00:00Z'
        ]
        retentionDuration: {
          count: 30
          durationType: 'Days'
        }
      }
    }
    instantRpRetentionRangeInDays: 2
    timeZone: 'UTC'
    protectedItemsCount: 0
  }
}

resource vaults_ThievingVault_name_HourlyLogBackup 'Microsoft.RecoveryServices/vaults/backupPolicies@2024-04-30-preview' = {
  parent: vaults_ThievingVault_name_resource
  name: 'HourlyLogBackup'
  properties: {
    backupManagementType: 'AzureWorkload'
    workLoadType: 'SQLDataBase'
    settings: {
      timeZone: 'UTC'
      issqlcompression: false
      isCompression: false
    }
    subProtectionPolicy: [
      {
        policyType: 'Full'
        schedulePolicy: {
          schedulePolicyType: 'SimpleSchedulePolicy'
          scheduleRunFrequency: 'Daily'
          scheduleRunTimes: [
            '2024-10-31T07:30:00Z'
          ]
          scheduleWeeklyFrequency: 0
        }
        retentionPolicy: {
          retentionPolicyType: 'LongTermRetentionPolicy'
          dailySchedule: {
            retentionTimes: [
              '2024-10-31T07:30:00Z'
            ]
            retentionDuration: {
              count: 30
              durationType: 'Days'
            }
          }
        }
      }
      {
        policyType: 'Log'
        schedulePolicy: {
          schedulePolicyType: 'LogSchedulePolicy'
          scheduleFrequencyInMins: 60
        }
        retentionPolicy: {
          retentionPolicyType: 'SimpleRetentionPolicy'
          retentionDuration: {
            count: 30
            durationType: 'Days'
          }
        }
      }
    ]
    protectedItemsCount: 0
  }
}

resource vaults_ThievingVault_name_sfghsrghsrth_6312693851603580223_backup_ce4585f8_dade_42b9_8edc_567ecb2e282b 'Microsoft.RecoveryServices/vaults/privateEndpointConnections@2024-04-30-preview' = {
  parent: vaults_ThievingVault_name_resource
  name: 'sfghsrghsrth.6312693851603580223.backup.ce4585f8-dade-42b9-8edc-567ecb2e282b'
  location: 'centralus'
  properties: {
    provisioningState: 'Succeeded'
    privateEndpoint: {
      id: privateEndpoints_sfghsrghsrth_externalid
    }
    groupIds: [
      'AzureBackup'
    ]
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'None'
      actionsRequired: 'None'
    }
  }
}

resource vaults_ThievingVault_name_defaultAlertSetting 'Microsoft.RecoveryServices/vaults/replicationAlertSettings@2024-04-01' = {
  parent: vaults_ThievingVault_name_resource
  name: 'defaultAlertSetting'
  properties: {
    sendToOwners: 'DoNotSend'
    customEmailAddresses: []
  }
}

resource vaults_ThievingVault_name_default 'Microsoft.RecoveryServices/vaults/replicationVaultSettings@2024-04-01' = {
  parent: vaults_ThievingVault_name_resource
  name: 'default'
  properties: {}
}
