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

// param enableRecoveryServiceVault = true

param dnsServers = [
  '168.63.129.16'
]

// Subscription(s)

param subscriptionId = '5a718e73-cce6-49e2-af77-023ea133c332' // Current Subscription ID (Identity)
param conSubscriptionId = '82d21ec8-4b6a-4bf0-9716-96b38d9abb43' // Connectivity Subscription ID

// Paired Regions

param locations = [
  'westus2' // Primary Region
 // 'eastus2' // Secondary Region
]

// Resource Group Names

var resourceGroupName_Networks = [
  'idnwus2networkrg'
  'idneus2networkrg'
]
param resourceGroupName_Network = [
  'idnwus2networkrg'
  'idneus2networkrg'
]

// Resource Group Names (Private DNS)

param resourceGroupName_PrivateDns = 'conwus2dnsrg'

// Virtual Network Names

var virtualNetworkNamePrimary = 'idnwus2vnet'
var virtualNetworkNameSecondary = 'idneus2vnet'

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
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Networks[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}virtualmachinesn${nsgSuffix}'
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
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Networks[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}virtualmachinesn${nsgSuffix}'
    serviceEndpoints: []
  }
  {
    name: '${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn'
    addressPrefix: '10.4.1.0/24'
    delegation: ''
    networkSecurityGroupResourceId: '/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName_Network[0]}/providers/Microsoft.Network/networkSecurityGroups/${virtualNetworkNamePrimary}${nameSeparator}privateendpointsn${nsgSuffix}'
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

// Storage Account (Diagnostics)

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
