targetScope = 'subscription'

// Deployment Boolean Parameters

param enableUserAssignedManagedIdentity bool
param enableNetworkSecurityGroups bool
param enableVirtualNetwork bool
param enableOperationalInsights bool
param enableKeyVault bool
param enableStorageAccount bool
param enableRecoveryServiceVault bool

// Deployment Options

param subscriptionId string
param conSubscriptionId string
param locations array
param tags object
param nameSeparator string

// Private DNS Zone Location

param resourceGroupName_PrivateDns string

// Resource Names

param uamiName array
param operationalInsightsName array
param keyVaultName array
param storageAccountName array

// DNS Servers

param dnsServers array

// Resource Maps

param keyVault object
param storageAccount object

// Resource Suffixes

param nsgSuffix string
param peSuffix string
param nicSuffix string

// Resource Group Parameters

param resourceGroupName_Network array

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
    ]
  }
]

// Key Vault

module vault 'br/public:avm/res/key-vault/vault:0.9.0' = [
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
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
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
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
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
                privateDnsZoneResourceId: '/subscriptions/${conSubscriptionId}/resourceGroups/${resourceGroupName_PrivateDns}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
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

// Availability Set

module modAvailabilitySet 'br/public:avm/res/compute/availability-set:0.2.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'availabilitySetDeployment${i}'
    params: {
      // Required parameters
      name: 'casmax001'
      // Non-required parameters
      location: '<location>'
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      proximityPlacementGroupResourceId: '<proximityPlacementGroupResourceId>'
      roleAssignments: [
        {
          name: 'd9d13442-232d-4861-9ab9-bad5e90c4f71'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Owner'
        }
        {
          name: '<name>'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        }
        {
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
        }
      ]
      tags: {
        Environment: 'Non-Prod'
        'hidden-title': 'This is visible in the resource name'
        Role: 'DeploymentValidation'
      }
    }
  }
]

// Windows Virtual Machine

module modVirtualMachine_Windows 'br/public:avm/res/compute/virtual-machine:0.8.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'virtualMachineDeploymentWindows${i}'
    params: {
      // Required parameters
      adminUsername: 'VMAdmin'
      imageReference: {
        offer: 'WindowsServer'
        publisher: 'MicrosoftWindowsServer'
        sku: '2019-datacenter'
        version: 'latest'
      }
      name: 'cvmwinmax'
      nicConfigurations: [
        {
          deleteOption: 'Delete'
          diagnosticSettings: [
            {
              eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
              eventHubName: '<eventHubName>'
              metricCategories: [
                {
                  category: 'AllMetrics'
                }
              ]
              name: 'customSetting'
              storageAccountResourceId: '<storageAccountResourceId>'
              workspaceResourceId: '<workspaceResourceId>'
            }
          ]
          enableIPForwarding: true
          ipConfigurations: [
            {
              applicationSecurityGroups: [
                {
                  id: '<id>'
                }
              ]
              diagnosticSettings: [
                {
                  eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
                  eventHubName: '<eventHubName>'
                  metricCategories: [
                    {
                      category: 'AllMetrics'
                    }
                  ]
                  name: 'customSetting'
                  storageAccountResourceId: '<storageAccountResourceId>'
                  workspaceResourceId: '<workspaceResourceId>'
                }
              ]
              loadBalancerBackendAddressPools: [
                {
                  id: '<id>'
                }
              ]
              name: 'ipconfig01'
              pipConfiguration: {
                publicIPAddressResourceId: '<publicIPAddressResourceId>'
                roleAssignments: [
                  {
                    name: 'e962e7c1-261a-4afd-b5ad-17a640a0b7bc'
                    principalId: '<principalId>'
                    principalType: 'ServicePrincipal'
                    roleDefinitionIdOrName: 'Owner'
                  }
                  {
                    principalId: '<principalId>'
                    principalType: 'ServicePrincipal'
                    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
                  }
                  {
                    principalId: '<principalId>'
                    principalType: 'ServicePrincipal'
                    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
                  }
                ]
              }
              subnetResourceId: '<subnetResourceId>'
            }
          ]
          name: 'nic-test-01'
          roleAssignments: [
            {
              name: '95fc1cc2-05ed-4f5a-a22c-a6ca852df7e7'
              principalId: '<principalId>'
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: 'Owner'
            }
            {
              principalId: '<principalId>'
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
            }
            {
              principalId: '<principalId>'
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
            }
          ]
        }
      ]
      osDisk: {
        caching: 'ReadWrite'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        name: 'osdisk01'
      }
      osType: 'Windows'
      vmSize: 'Standard_D2s_v3'
      zone: 2
      // Non-required parameters
      adminPassword: '<adminPassword>'
      autoShutdownConfig: {
        dailyRecurrenceTime: '19:00'
        notificationEmail: 'test@contoso.com'
        notificationLocale: 'en'
        notificationStatus: 'Enabled'
        notificationTimeInMinutes: 30
        status: 'Enabled'
        timeZone: 'UTC'
      }
      backupPolicyName: '<backupPolicyName>'
      backupVaultName: '<backupVaultName>'
      backupVaultResourceGroup: '<backupVaultResourceGroup>'
      computerName: 'winvm1'
      dataDisks: [
        {
          caching: 'None'
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 128
          lun: 0
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          name: 'datadisk01'
        }
        {
          caching: 'None'
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 128
          lun: 1
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          name: 'datadisk02'
        }
      ]
      enableAutomaticUpdates: true
      encryptionAtHost: false
      extensionAadJoinConfig: {
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionAntiMalwareConfig: {
        enabled: true
        settings: {
          AntimalwareEnabled: 'true'
          Exclusions: {
            Extensions: '.ext1;.ext2'
            Paths: 'c:\\excluded-path-1;c:\\excluded-path-2'
            Processes: 'excludedproc1.exe;excludedproc2.exe'
          }
          RealtimeProtectionEnabled: 'true'
          ScheduledScanSettings: {
            day: '7'
            isEnabled: 'true'
            scanType: 'Quick'
            time: '120'
          }
        }
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionAzureDiskEncryptionConfig: {
        enabled: true
        settings: {
          EncryptionOperation: 'EnableEncryption'
          KekVaultResourceId: '<KekVaultResourceId>'
          KeyEncryptionAlgorithm: 'RSA-OAEP'
          KeyEncryptionKeyURL: '<KeyEncryptionKeyURL>'
          KeyVaultResourceId: '<KeyVaultResourceId>'
          KeyVaultURL: '<KeyVaultURL>'
          ResizeOSDisk: 'false'
          tags: {
            Environment: 'Non-Prod'
            'hidden-title': 'This is visible in the resource name'
            Role: 'DeploymentValidation'
          }
          VolumeType: 'All'
        }
      }
      extensionCustomScriptConfig: {
        enabled: true
        fileData: [
          {
            storageAccountId: '<storageAccountId>'
            uri: '<uri>'
          }
        ]
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionCustomScriptProtectedSetting: {
        commandToExecute: '<commandToExecute>'
      }
      extensionDependencyAgentConfig: {
        enableAMA: true
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionDSCConfig: {
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionMonitoringAgentConfig: {
        dataCollectionRuleAssociations: [
          {
            dataCollectionRuleResourceId: '<dataCollectionRuleResourceId>'
            name: 'SendMetricsToLAW'
          }
        ]
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionNetworkWatcherAgentConfig: {
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      location: '<location>'
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          '<managedIdentityResourceId>'
        ]
      }
      patchMode: 'AutomaticByPlatform'
      proximityPlacementGroupResourceId: '<proximityPlacementGroupResourceId>'
      rebootSetting: 'IfRequired'
      roleAssignments: [
        {
          name: 'c70e8c48-6945-4607-9695-1098ba5a86ed'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Owner'
        }
        {
          name: '<name>'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        }
        {
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
        }
      ]
      tags: {
        Environment: 'Non-Prod'
        'hidden-title': 'This is visible in the resource name'
        Role: 'DeploymentValidation'
      }
    }
  }
]

// Linux Virtual Machine

module modVirtualMachine_Linux 'br/public:avm/res/compute/virtual-machine:0.8.0' = [
  for i in range(0, length(locations)): if (enableStorageAccount) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'virtualMachineDeploymentLinux${i}'
    params: {
      // Required parameters
      adminUsername: 'localAdministrator'
      imageReference: {
        offer: '0001-com-ubuntu-server-focal'
        publisher: 'Canonical'
        sku: '<sku>'
        version: 'latest'
      }
      name: 'cvmlinmax'
      nicConfigurations: [
        {
          deleteOption: 'Delete'
          diagnosticSettings: [
            {
              eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
              eventHubName: '<eventHubName>'
              metricCategories: [
                {
                  category: 'AllMetrics'
                }
              ]
              name: 'customSetting'
              storageAccountResourceId: '<storageAccountResourceId>'
              workspaceResourceId: '<workspaceResourceId>'
            }
          ]
          ipConfigurations: [
            {
              applicationSecurityGroups: [
                {
                  id: '<id>'
                }
              ]
              diagnosticSettings: [
                {
                  eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
                  eventHubName: '<eventHubName>'
                  metricCategories: [
                    {
                      category: 'AllMetrics'
                    }
                  ]
                  name: 'customSetting'
                  storageAccountResourceId: '<storageAccountResourceId>'
                  workspaceResourceId: '<workspaceResourceId>'
                }
              ]
              loadBalancerBackendAddressPools: [
                {
                  id: '<id>'
                }
              ]
              name: 'ipconfig01'
              pipConfiguration: {
                publicIpNameSuffix: '-pip-01'
                roleAssignments: [
                  {
                    name: '696e6067-3ddc-4b71-bf97-9caebeba441a'
                    principalId: '<principalId>'
                    principalType: 'ServicePrincipal'
                    roleDefinitionIdOrName: 'Owner'
                  }
                  {
                    principalId: '<principalId>'
                    principalType: 'ServicePrincipal'
                    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
                  }
                  {
                    principalId: '<principalId>'
                    principalType: 'ServicePrincipal'
                    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
                  }
                ]
                zones: [
                  1
                  2
                  3
                ]
              }
              subnetResourceId: '<subnetResourceId>'
            }
          ]
          name: 'nic-test-01'
          roleAssignments: [
            {
              name: 'ff72f58d-a3cf-42fd-9c27-c61906bdddfe'
              principalId: '<principalId>'
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: 'Owner'
            }
            {
              principalId: '<principalId>'
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
            }
            {
              principalId: '<principalId>'
              principalType: 'ServicePrincipal'
              roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
            }
          ]
        }
      ]
      osDisk: {
        caching: 'ReadOnly'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        diskSizeGB: 128
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        name: 'osdisk01'
      }
      osType: 'Linux'
      vmSize: 'Standard_D2s_v3'
      zone: 1
      // Non-required parameters
      backupPolicyName: '<backupPolicyName>'
      backupVaultName: '<backupVaultName>'
      backupVaultResourceGroup: '<backupVaultResourceGroup>'
      computerName: 'linvm1'
      dataDisks: [
        {
          caching: 'ReadWrite'
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 128
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          name: 'datadisk01'
        }
        {
          caching: 'ReadWrite'
          createOption: 'Empty'
          deleteOption: 'Delete'
          diskSizeGB: 128
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          name: 'datadisk02'
        }
      ]
      disablePasswordAuthentication: true
      enableAutomaticUpdates: true
      encryptionAtHost: false
      extensionAadJoinConfig: {
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionAzureDiskEncryptionConfig: {
        enabled: true
        settings: {
          EncryptionOperation: 'EnableEncryption'
          KekVaultResourceId: '<KekVaultResourceId>'
          KeyEncryptionAlgorithm: 'RSA-OAEP'
          KeyEncryptionKeyURL: '<KeyEncryptionKeyURL>'
          KeyVaultResourceId: '<KeyVaultResourceId>'
          KeyVaultURL: '<KeyVaultURL>'
          ResizeOSDisk: 'false'
          VolumeType: 'All'
        }
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionCustomScriptConfig: {
        enabled: true
        fileData: [
          {
            storageAccountId: '<storageAccountId>'
            uri: '<uri>'
          }
        ]
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionCustomScriptProtectedSetting: {
        commandToExecute: '<commandToExecute>'
      }
      extensionDependencyAgentConfig: {
        enableAMA: true
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionDSCConfig: {
        enabled: false
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionMonitoringAgentConfig: {
        dataCollectionRuleAssociations: [
          {
            dataCollectionRuleResourceId: '<dataCollectionRuleResourceId>'
            name: 'SendMetricsToLAW'
          }
        ]
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      extensionNetworkWatcherAgentConfig: {
        enabled: true
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      location: '<location>'
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          '<managedIdentityResourceId>'
        ]
      }
      patchMode: 'AutomaticByPlatform'
      publicKeys: [
        {
          keyData: '<keyData>'
          path: '/home/localAdministrator/.ssh/authorized_keys'
        }
      ]
      rebootSetting: 'IfRequired'
      roleAssignments: [
        {
          name: 'eb01de52-d2be-4272-a7b9-13de6c399e27'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Owner'
        }
        {
          name: '<name>'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        }
        {
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
        }
      ]
      tags: {
        Environment: 'Non-Prod'
        'hidden-title': 'This is visible in the resource name'
        Role: 'DeploymentValidation'
      }
    }
  }
]

// Recovery Services Vault

module modRecoveryServiceVault 'br/public:avm/res/recovery-services/vault:0.5.1' = [
  for i in range(0, length(locations)): if (enableStorageAccount) {
    scope: resourceGroup(resourceGroupName_Network[i])
    name: 'vaultDeployment${i}'
    params: {
      name: 'rsvmax001'
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
          eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
          eventHubName: '<eventHubName>'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          name: 'customSetting'
          storageAccountResourceId: '<storageAccountResourceId>'
          workspaceResourceId: '<workspaceResourceId>'
        }
      ]
      location: '<location>'
      lock: {}
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          '<managedIdentityResourceId>'
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
          ipConfigurations: [
            {
              name: 'myIpConfig-1'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-tel1'
                privateIPAddress: '10.0.0.10'
              }
            }
            {
              name: 'myIPconfig-2'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-prot2'
                privateIPAddress: '10.0.0.11'
              }
            }
            {
              name: 'myIPconfig-3'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-srs1'
                privateIPAddress: '10.0.0.12'
              }
            }
            {
              name: 'myIPconfig-4'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-rcm1'
                privateIPAddress: '10.0.0.13'
              }
            }
            {
              name: 'myIPconfig-5'
              properties: {
                groupId: 'AzureSiteRecovery'
                memberName: 'SiteRecovery-id1'
                privateIPAddress: '10.0.0.14'
              }
            }
          ]
          privateDnsZoneGroup: {
            privateDnsZoneGroupConfigs: [
              {
                privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
              }
            ]
          }
          subnetResourceId: '<subnetResourceId>'
          tags: {
            Environment: 'Non-Prod'
            'hidden-title': 'This is visible in the resource name'
            Role: 'DeploymentValidation'
          }
        }
      ]
      replicationAlertSettings: {
        customEmailAddresses: [
          'test.user@testcompany.com'
        ]
        locale: 'en-US'
        sendToOwners: 'Send'
      }
      roleAssignments: [
        {
          name: '35288372-e6b4-4333-9ee6-dd997b96d52b'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Owner'
        }
        {
          name: '<name>'
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
        }
        {
          principalId: '<principalId>'
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
        }
      ]
      securitySettings: {
        immutabilitySettings: {
          state: 'Unlocked'
        }
      }
      tags: {
        Environment: 'Non-Prod'
        'hidden-title': 'This is visible in the resource name'
        Role: 'DeploymentValidation'
      }
    }
  }
]
