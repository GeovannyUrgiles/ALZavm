using 'identity-main.bicep'

// IaC Version Number

var version = 'v1.0.0'

//-// Deployment Options

// Virtual Network
param enableVirtualNetwork = true
param enableNetworkSecurityGroups = true

// Supporting Resources
param enableUserAssignedManagedIdentity = true
param enableOperationalInsights = true
param enableKeyVault = true
param enableStorageAccount = true

param enableRecoveryServiceVault = true

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

// Resource Group Names

param resourceGroupName_Network = [
  'idnwus2networkrg'
  'idneus2networkrg'
]

// Resource Group Names (Private DNS)

param resourceGroupName_PrivateDns = 'conwus2dnsrg'

// Virtual Network Names

var virtualNetworkNamePrimary = 'idnwus2vnet'
var virtualNetworkNameSecondary = 'idneus2vnet'

// Virtual Machine Names
param virtualMachineName_Windows = [
  'idnwus2dcvm01'
  'idneus2dcvm01'
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
  'idnwus2oiw'
  'idneus2oiw'
]
param uamiName = [
  'idnwus2mi'
  'idneus2mi'
]
param keyVaultName = [
  'idnwus2kv01'
  'idneus2kv01'
]
param storageAccountName = [
  'idnwus2diagsa01'
  'idneus2diagsa01'
]

param dataCollectionRuleName = [
  'idnwus2dcr01'
  'idneus2dcr01'
]
// Key Vault Properties

param keyVault = {
  sku: 'standard' // standard | premium (lowercase) (premium SKU requires HSM)
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

// Resource Group Lock

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
  'idnwus2avset'
  'idneus2avset'
]

param availabilitySet = {
  proximityPlacementGroupResourceId: ''
  platformFaultDomainCount: 2
  platformUpdateDomainCount: 5
}

// Virtual Machine Properties (Windows)

param virtualMachine_Windows = {
  vmSize: 'Standard_F2s_v2' // Standard_DS1_v2 | Standard_DS2_v2 | Standard_DS3_v2 | Standard_DS4_v2 | Standard_DS5_v2 | Standard_DS11_v2 | Standard_DS12_v2 | Standard_DS13_v2 | Standard_DS14_v2 | Standard_DS15_v2 | Standard_D1_v2 | Standard_D2_v2 | Standard_D3_v2 | Standard_D4_v2 | Standard_D5_v2 | Standard_D11_v2 | Standard_D12_v2 | Standard_D13_v2 | Standard_D14_v2 | Standard_D15_v2 | Standard_D2s_v3 | Standard_D4s_v3 | Standard_D8s_v3 | Standard_D16s_v3 | Standard_D32s_v3 | Standard_D48s_v3 | Standard_D64s_v3 | Standard_D2_v3 | Standard_D4_v3 | Standard_D8_v3 | Standard_D16_v3 | Standard_D32_v3 | Standard_D48_v3 | Standard_D64_v3 | Standard_D2s_v4 | Standard_D4s_v4 | Standard_D8s_v4 | Standard_D16s_v4 | Standard_D32s_v4 | Standard_D48s_v4 | Standard_D64s_v4 | Standard_D2_v4 | Standard_D4_v4 | Standard_D8_v4 | Standard_D16_v4 | Standard_D32_v4 | Standard_D48_v4 | Standard_D64_v4 | Standard_D2ds_v4 | Standard_D4ds_v4 | Standard_D8ds_v4 | Standard_D16ds_v4 | Standard_D32ds_v4 | Standard_D48ds_v4 | Standard_D64ds_v4 | Standard_D2s_v5 | Standard_D4s_v5 | Standard_D8s_v5 | Standard_D16s_v5 | Standard_D32s_v5 | Standard_D48s_v5 | Standard_D64s_v5 | Standard_D2_v5 | Standard_D4_v5 | Standard_D8_v5 | Standard_D16_v5 | Standard_D32_v5 | Standard_D48_v5 | Standard_D64_v5 | Standard_D2ds_v5 | Standard_D4ds_v5 | Standard_D8ds_v5 | Standard_D16ds_v5 | Standard_D32ds_v5 | Standard_D48ds_v5 | Standard_D64ds_v5 | Standard_D2s_v6 |
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
      storageAccountType: 'Premium_LRS' // Standard_LRS | Premium_LRS | StandardSSD_LRS | UltraSSD_LRS
    }
  }
  dataDisks: {
    caching: 'None'
    createOption: 'Empty'
    deleteOption: 'Delete'
    diskSizeGB: 128
    lun: 0
    managedDisk: {
      storageAccountType: 'Premium_LRS' // Standard_LRS | Premium_LRS | StandardSSD_LRS | UltraSSD_LRS
    }
  }
  autoShutdownConfig: {
    dailyRecurrenceTime: '17:00'
    notificationEmail: 'john.kaufman@neudesic.com'
    notificationLocale: 'en'
    notificationStatus: 'Enabled'
    notificationTimeInMinutes: 30
    status: 'Enabled'
    timeZone: 'CST'
  }
  enableAutoUpdate: true
  patchMode: 'AutomaticByPlatform'
  rebootSetting: 'IfRequired'
  proximityPlacementGroupResourceId: ''

  // enableBackup: true
  enableMonitoring: true
  // enableUpdateManagement: true
  enableTelemetry: true
  extensionAntiMalwareConfig: {
    enabled: true
    settings: {
      AntimalwareEnabled: 'true'
      Exclusions: {
        Extensions: '' //  to exclude, example: '.ext1;.ext2'
        Paths: '' // to exclude, example: 'c:\\excluded-path-1;c:\\excluded-path-2'
        Processes: '' // to exclude, example: 'excludedproc1.exe;excludedproc2.exe'
      }
      RealtimeProtectionEnabled: 'true'
      ScheduledScanSettings: {
        day: '7'
        isEnabled: 'true'
        scanType: 'Quick'
        time: '120'
      }
    }
  }
  extensionAzureDiskEncryptionConfig: {
    enabled: true
    settings: {
      EncryptionOperation: 'EnableEncryption' // EnableEncryption | RotateEncryptionKey | DisableEncryption
      KekVaultResourceId: ''
      KeyEncryptionAlgorithm: 'RSA-OEP' // RSA-OAEP | RSA-OAEP-256 | RSA1_5
      KeyEncryptionKeyURL: ''
      KeyVaultResourceId: ''
      KeyVaultURL: ''
      ResizeOSDisk: false // true | false
      tags: tags
      VolumeType: 'All' // All | OS | Data
    }
  }
  extensionCustomScriptConfig: {
    enabled: false
    fileData: [
      {
        storageAccountId: '' // Storage Account ID
        uri: '' // URI to the script
      }
    ]
    tags: tags
  }
  extensionCustomScriptProtectedSetting: {
    commandToExecute: '' // Command to execute
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
  accountTier: 'Standard' // Standard | Premium
  requireInfrastructureEncryption: true
  sasExpirationPeriod: '180.00:00:00'
  skuName: 'Standard_LRS' // Standard_LRS | Standard_GRS | Standard_RAGRS | Standard_ZRS | Premium_LRS | Premium_ZRS | Premium_GRS | Premium_RAGRS
  accountReplicationType: 'LRS' // LRS | GRS | RAGRS | ZRS | GZRS | RA_GRS
  accountKind: 'StorageV2' // Storage | StorageV2 | BlobStorage | BlockBlobStorage
  accountAccessTier: 'Hot' // Hot | Cool | Archive
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
    bypass: 'AzureServices' // AzureServices | None
    defaultAction: 'Deny'
    ipRules: []
  }
}
