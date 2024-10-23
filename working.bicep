param dnsForwardingRulesets_fr_name string = 'fr'
param dnsResolvers_conwus2dns_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/dnsResolvers/conwus2dns'
param virtualNetworks_conwus2vnet_externalid string = '/subscriptions/82d21ec8-4b6a-4bf0-9716-96b38d9abb43/resourceGroups/conwus2networkrg/providers/Microsoft.Network/virtualNetworks/conwus2vnet'

resource dnsForwardingRulesets_fr_name_resource 'Microsoft.Network/dnsForwardingRulesets@2022-07-01' = {
  name: dnsForwardingRulesets_fr_name
  location: 'westus2'
  tags: {
    CostCenter: 'Thieving Cat Corporate'
  }
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: '${dnsResolvers_conwus2dns_externalid}/outboundEndpoints/OutboundEndpoint'
      }
    ]
  }
}

resource dnsForwardingRulesets_fr_name_conwus2vnet_link 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2022-07-01' = {
  parent: dnsForwardingRulesets_fr_name_resource
  name: 'conwus2vnet-link'
  properties: {
    virtualNetwork: {
      id: virtualNetworks_conwus2vnet_externalid
    }
  }
}



module storageAccount 'br/public:avm/res/storage/storage-account:0.14.1' = {
  name: 'storageAccountDeployment'
  params: {
    // Required parameters
    name: 'ssamax001'
    // Non-required parameters
    allowBlobPublicAccess: false
    blobServices: {
      automaticSnapshotPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 10
      containerDeleteRetentionPolicyEnabled: true
      containers: [
        {
          enableNfsV3AllSquash: true
          enableNfsV3RootSquash: true
          name: 'avdscripts'
          publicAccess: 'None'
          roleAssignments: [
            {
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
        {
          allowProtectedAppendWrites: false
          enableWORM: true
          metadata: {
            testKey: 'testValue'
          }
          name: 'archivecontainer'
          publicAccess: 'None'
          WORMRetention: 666
        }
      ]
      deleteRetentionPolicyDays: 9
      deleteRetentionPolicyEnabled: true
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
      lastAccessTimeTrackingPolicyEnabled: true
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
    enableHierarchicalNamespace: true
    enableNfsV3: true
    enableSftp: true
    fileServices: {
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
      shares: [
        {
          accessTier: 'Hot'
          name: 'avdprofiles'
          roleAssignments: [
            {
              name: 'cff1213b-7877-4425-b67c-bb1de8950dfb'
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
          shareQuota: 5120
        }
        {
          name: 'avdprofiles2'
          shareQuota: 102400
        }
      ]
    }
    largeFileSharesState: 'Enabled'
    localUsers: [
      {
        hasSharedKey: false
        hasSshKey: true
        hasSshPassword: false
        homeDirectory: 'avdscripts'
        name: 'testuser'
        permissionScopes: [
          {
            permissions: 'r'
            resourceName: 'avdscripts'
            service: 'blob'
          }
        ]
        storageAccountName: 'ssamax001'
      }
    ]
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
    managementPolicyRules: [
      {
        definition: {
          actions: {
            baseBlob: {
              delete: {
                daysAfterModificationGreaterThan: 30
              }
              tierToCool: {
                daysAfterLastAccessTimeGreaterThan: 5
              }
            }
          }
          filters: {
            blobIndexMatch: [
              {
                name: 'BlobIndex'
                op: '=='
                value: '1'
              }
            ]
            blobTypes: [
              'blockBlob'
            ]
            prefixMatch: [
              'sample-container/log'
            ]
          }
        }
        enabled: true
        name: 'FirstRule'
        type: 'Lifecycle'
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: '1.1.1.1'
        }
      ]
      resourceAccessRules: [
        {
          resourceId: '<resourceId>'
          tenantId: '<tenantId>'
        }
      ]
      virtualNetworkRules: [
        {
          action: 'Allow'
          id: '<id>'
        }
      ]
    }
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'blob'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'blob'
        subnetResourceId: '<subnetResourceId>'
      }
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'table'
        subnetResourceId: '<subnetResourceId>'
      }
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'queue'
        subnetResourceId: '<subnetResourceId>'
      }
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'file'
        subnetResourceId: '<subnetResourceId>'
      }
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'web'
        subnetResourceId: '<subnetResourceId>'
      }
      {
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            {
              privateDnsZoneResourceId: '<privateDnsZoneResourceId>'
            }
          ]
        }
        service: 'dfs'
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    queueServices: {
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
      queues: [
        {
          metadata: {
            key1: 'value1'
            key2: 'value2'
          }
          name: 'queue1'
          roleAssignments: [
            {
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
        {
          metadata: {}
          name: 'queue2'
        }
      ]
    }
    requireInfrastructureEncryption: true
    roleAssignments: [
      {
        name: '30b99723-a3d8-4e31-8872-b80c960d62bd'
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
    sasExpirationPeriod: '180.00:00:00'
    skuName: 'Standard_LRS'
    tableServices: {
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
      tables: [
        {
          name: 'table1'
          roleAssignments: [
            {
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
        {
          name: 'table2'
          roleAssignments: [
            {
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
    }
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
