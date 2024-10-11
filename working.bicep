param automationAccounts_srcmgmtwus2aa_name string = 'srcmgmtwus2aa'
param privateEndpoints_srcmgmtwus2aape_externalid string = '/subscriptions/581f65b8-4108-48a3-8458-418c68484734/resourceGroups/srcmgmtwus2automationrg/providers/Microsoft.Network/privateEndpoints/srcmgmtwus2aape'

resource automationAccounts_srcmgmtwus2aa_name_resource 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccounts_srcmgmtwus2aa_name
  location: 'westus2'
  tags: {
    company: 'src'
    product: 'robots'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: true
    disableLocalAuth: false
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Azure 'Microsoft.Automation/automationAccounts/connectionTypes@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Azure'
  properties: {
    isGlobal: true
    fieldDefinitions: {
      AutomationCertificateName: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      SubscriptionID: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
    }
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureClassicCertificate 'Microsoft.Automation/automationAccounts/connectionTypes@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureClassicCertificate'
  properties: {
    isGlobal: true
    fieldDefinitions: {
      SubscriptionName: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      SubscriptionId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      CertificateAssetName: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
    }
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureServicePrincipal 'Microsoft.Automation/automationAccounts/connectionTypes@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureServicePrincipal'
  properties: {
    isGlobal: true
    fieldDefinitions: {
      ApplicationId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      TenantId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      CertificateThumbprint: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
      SubscriptionId: {
        isEncrypted: false
        isOptional: false
        type: 'System.String'
      }
    }
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AuditPolicyDsc 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AuditPolicyDsc'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Accounts 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Accounts'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Advisor 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Advisor'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Aks 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Aks'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_AnalysisServices 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.AnalysisServices'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ApiManagement 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ApiManagement'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_AppConfiguration 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.AppConfiguration'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ApplicationInsights 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ApplicationInsights'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Attestation 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Attestation'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Automation 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Automation'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Batch 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Batch'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Billing 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Billing'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Cdn 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Cdn'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_CloudService 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.CloudService'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_CognitiveServices 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.CognitiveServices'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Compute 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Compute'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ContainerInstance 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ContainerInstance'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ContainerRegistry 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ContainerRegistry'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_CosmosDB 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.CosmosDB'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DataBoxEdge 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DataBoxEdge'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Databricks 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Databricks'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DataFactory 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DataFactory'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DataLakeAnalytics 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DataLakeAnalytics'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DataLakeStore 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DataLakeStore'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DataShare 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DataShare'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DeploymentManager 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DeploymentManager'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DesktopVirtualization 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DesktopVirtualization'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_DevTestLabs 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.DevTestLabs'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Dns 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Dns'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_EventGrid 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.EventGrid'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_EventHub 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.EventHub'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_FrontDoor 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.FrontDoor'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Functions 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Functions'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_HDInsight 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.HDInsight'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_HealthcareApis 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.HealthcareApis'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_IotHub 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.IotHub'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_KeyVault 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.KeyVault'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Kusto 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Kusto'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_LogicApp 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.LogicApp'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_MachineLearning 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.MachineLearning'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Maintenance 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Maintenance'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ManagedServiceIdentity 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ManagedServiceIdentity'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ManagedServices 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ManagedServices'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_MarketplaceOrdering 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.MarketplaceOrdering'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Media 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Media'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Migrate 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Migrate'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Monitor 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Monitor'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_MySql 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.MySql'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Network 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Network'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_NotificationHubs 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.NotificationHubs'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_OperationalInsights 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.OperationalInsights'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_PolicyInsights 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.PolicyInsights'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_PostgreSql 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.PostgreSql'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_PowerBIEmbedded 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.PowerBIEmbedded'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_PrivateDns 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.PrivateDns'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_RecoveryServices 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.RecoveryServices'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_RedisCache 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.RedisCache'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_RedisEnterpriseCache 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.RedisEnterpriseCache'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Relay 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Relay'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ResourceMover 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ResourceMover'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Resources 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Resources'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Security 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Security'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_SecurityInsights 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.SecurityInsights'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ServiceBus 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ServiceBus'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_ServiceFabric 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.ServiceFabric'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_SignalR 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.SignalR'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Sql 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Sql'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_SqlVirtualMachine 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.SqlVirtualMachine'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_StackHCI 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.StackHCI'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Storage 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Storage'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_StorageSync 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.StorageSync'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_StreamAnalytics 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.StreamAnalytics'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Support 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Support'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Synapse 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Synapse'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_TrafficManager 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.TrafficManager'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Az_Websites 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Az.Websites'
  properties: {
    contentLink: {}
  }
}

resource Microsoft_Automation_automationAccounts_modules_automationAccounts_srcmgmtwus2aa_name_Azure 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Azure'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Azure_Storage 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Azure.Storage'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureRM_Automation 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureRM.Automation'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureRM_Compute 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureRM.Compute'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureRM_Profile 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureRM.Profile'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureRM_Resources 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureRM.Resources'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureRM_Sql 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureRM.Sql'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_AzureRM_Storage 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'AzureRM.Storage'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_ComputerManagementDsc 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'ComputerManagementDsc'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_GPRegistryPolicyParser 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'GPRegistryPolicyParser'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Microsoft_PowerShell_Core 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Microsoft.PowerShell.Core'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Microsoft_PowerShell_Diagnostics 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Microsoft.PowerShell.Diagnostics'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Microsoft_PowerShell_Management 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Microsoft.PowerShell.Management'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Microsoft_PowerShell_Security 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Microsoft.PowerShell.Security'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Microsoft_PowerShell_Utility 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Microsoft.PowerShell.Utility'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Microsoft_WSMan_Management 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Microsoft.WSMan.Management'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_Orchestrator_AssetManagement_Cmdlets 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'Orchestrator.AssetManagement.Cmdlets'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_PSDscResources 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'PSDscResources'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_SecurityPolicyDsc 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'SecurityPolicyDsc'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_StateConfigCompositeResources 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'StateConfigCompositeResources'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_xDSCDomainjoin 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'xDSCDomainjoin'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_xPowerShellExecutionPolicy 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'xPowerShellExecutionPolicy'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_xRemoteDesktopAdmin 'Microsoft.Automation/automationAccounts/modules@2022-08-08' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'xRemoteDesktopAdmin'
  properties: {
    contentLink: {}
  }
}

resource automationAccounts_srcmgmtwus2aa_name_d51c7e82_ae93_4321_9210_7508a2499418_9a76859f_1085_4ee2_a2f7_d80fecfa3384 'Microsoft.Automation/automationAccounts/privateEndpointConnections@2020-01-13-preview' = {
  parent: automationAccounts_srcmgmtwus2aa_name_resource
  name: 'd51c7e82-ae93-4321-9210-7508a2499418-9a76859f-1085-4ee2-a2f7-d80fecfa3384'
  properties: {
    privateEndpoint: {
      id: privateEndpoints_srcmgmtwus2aape_externalid
    }
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-approved'
    }
    groupIds: [
      'DSCAndHybridWorker'
    ]
  }
}

