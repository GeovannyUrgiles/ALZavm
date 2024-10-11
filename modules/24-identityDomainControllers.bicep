targetScope = 'subscription'

param tags object

param enableDomainControllers bool

// Resource Groups are defined in YAML
param identityActiveDirectoryResourceGroupName string

param identityKeyVaultResourceGroupName string
param AzureActiveDirectorySubnetId string
param logAnalyticsWorkspaceId string
param numberOfDCInstances int
param privateDNSZoneId string
param nameSeparator string
param CAFPrefix string
param location string

// Virtual Machines / Domain Controllers

@allowed([ // Domain Controller SKU
  '2008-R2-SP1'
  '2008-R2-SP1-smalldisk'
  '2012-Datacenter'
  '2012-datacenter-gensecond'
  '2012-Datacenter-smalldisk'
  '2012-datacenter-smalldisk-g2'
  '2012-R2-Datacenter'
  '2012-r2-datacenter-gensecond'
  '2012-R2-Datacenter-smalldisk'
  '2012-r2-datacenter-smalldisk-g2'
  '2016-Datacenter'
  '2016-datacenter-gensecond'
  '2016-datacenter-gs'
  '2016-Datacenter-Server-Core'
  '2016-datacenter-server-core-g2'
  '2016-Datacenter-Server-Core-smalldisk'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-Datacenter-smalldisk'
  '2016-datacenter-smalldisk-g2'
  '2016-Datacenter-with-Containers'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-with-containers-gs'
  '2019-Datacenter'
  '2019-Datacenter-Core'
  '2019-datacenter-core-g2'
  '2019-Datacenter-Core-smalldisk'
  '2019-datacenter-core-smalldisk-g2'
  '2019-Datacenter-Core-with-Containers'
  '2019-datacenter-core-with-containers-g2'
  '2019-Datacenter-Core-with-Containers-smalldisk'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-gs'
  '2019-Datacenter-smalldisk'
  '2019-datacenter-smalldisk-g2'
  '2019-Datacenter-with-Containers'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-gs'
  '2019-Datacenter-with-Containers-smalldisk'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2022-datacenter'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'
param domainToJoin string = '' // Active Directory / Set AD Domain Name to Join
param ouPath string = '' // Active Directory / Set OU Path Destination of new Virtual Machines
param numberOfDcInstances int = 1
@allowed([
  'Premium_LRS'
  'PremiumV2_LRS'
  'Premium_ZRS'
  'Standard_LRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'UltraSSD_LRS'
])
param vmDiskType string = 'StandardSSD_LRS'
param vmSize string = 'Standard_D2s_v5'

// Management Automation Resource Group Name
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: identityActiveDirectoryResourceGroupName
}

// Virtual Machines / Domain Controllers

module domainControllers 'virtualmachines/domainController.bicep' = if (enableDomainControllers == true) {
  scope: resourceGroup
  name: 'domainController'
  params: {
    OSVersion: OSVersion
    domainToJoin: domainToJoin
    ouPath: ouPath
    // administratorAccountUserName: ''
    // administratorAccountPassword: ''
    subnetId: AzureActiveDirectorySubnetId
    CAFPrefix: CAFPrefix
    numberOfDCInstances: numberOfDCInstances
    vmDiskType: vmDiskType
    vmSize: vmSize
    location: location
    nameSeparator: nameSeparator
    tags: tags

  }
}
