targetScope = 'subscription'

// Deployment Boolean Parameters

param enableUserAssignedManagedIdentity bool
param enableNetworkSecurityGroups bool
param enablePrivateDnsZones bool
param enableVirtualNetwork bool
param enableBastion bool
param enableOperationalInsights bool
param enableKeyVault bool
param enableStorageAccount bool

// Deployment Options

param subscriptionId string
param locations array
param tags object
param nameSeparator string

// Resource Names

param uamiName array
param bastionName array
param operationalInsightsName array
param keyVaultName array
param storageAccountName array

// DNS Servers

param dnsServers array

// Resource Maps

param keyVault object
param bastion object
param storageAccount object

// Resource Suffixes

param nsgSuffix string
param peSuffix string
param nicSuffix string

// Resource Group Parameters

param resourceGroupName_Network array
param resourceGroupName_Bastion array
param resourceGroupName_PrivateDns string

param roleAssignmentsNetwork array
param roleAssignmentsBastion array
param lock object

// Virtual Network Parameters

param virtualNetwork array
param subnets0 array
param subnets1 array

// Network Security Group Parameters

param securityRulesDefault array
param securityRulesBastion array

// VPN Gateway Site-to-Site

param vpnSiteLinks array
param vpnConnections array

// Firewall Policy Parameters

param ruleCollectionGroups array

// Private DNS Parameters

param privatelinkDnsZoneNames array

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

// Bastion Resource Group Deployment

module modResourceGroupBastion 'br/public:avm/res/resources/resource-group:0.4.0' = [
  for i in range(0, length(locations)): if (enableVirtualNetwork) {
    scope: subscription(subscriptionId)
    name: 'resourceGroupBastionDeployment${i}'
    params: {
      name: resourceGroupName_Bastion[0]
      tags: tags
      location: locations[0]
      // lock: lock
      roleAssignments: roleAssignmentsBastion
    }
  }
]

// User Assigned Managed Identity

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
      securityRules: (subnet.name == 'AzureBastionSubnet') ? securityRulesBastion : securityRulesDefault
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
      securityRules: (subnet.name == 'AzureBastionSubnet') ? securityRulesBastion : securityRulesDefault
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

// Private DNS Zones

module modPrivateDnsZones 'br/public:avm/res/network/private-dns-zone:0.6.0' = [
  for privatelinkDnsZoneName in privatelinkDnsZoneNames: if (enablePrivateDnsZones) {
    scope: resourceGroup(resourceGroupName_PrivateDns)
    name: '${privatelinkDnsZoneName}Deployment'
    params: {
      name: privatelinkDnsZoneName
      tags: tags
      virtualNetworkLinks: [
        for i in range(0, length(locations)): {
          registrationEnabled: false
          virtualNetworkResourceId: modVirtualNetwork[i].outputs.resourceId
        }
      ]
    }
    dependsOn: [
      modVirtualNetwork
    ]
  }
]

// Azure Bastion Host

module bastionHost 'br/public:avm/res/network/bastion-host:0.4.0' = [
  for i in range(0, length(locations)): if (enableBastion) {
    scope: resourceGroup(resourceGroupName_Bastion[0])
    name: 'AzureBastionDeployment${i}'
    params: {
      name: bastionName[0]
      location: locations[0]
      virtualNetworkResourceId: modVirtualNetwork[0].outputs.resourceId
      tags: tags
      disableCopyPaste: bastion.disableCopyPaste
      enableIpConnect: bastion.enableIpConnect
      enableFileCopy: bastion.enableFileCopy
      scaleUnits: bastion.scaleUnits
      enableShareableLink: bastion.enableShareableLink
      skuName: bastion.skuName
    }
    dependsOn: [
      modVirtualNetwork
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
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones.outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
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
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones.outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
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
                privateDnsZoneResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${modResourceGroupDnsZones.outputs.name}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
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
