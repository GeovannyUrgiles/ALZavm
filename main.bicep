// Set Default TargetScope

targetScope = 'tenant'

// Set Tenant ID

param tenantId string = 'cf09f4e1-9a2c-4ac3-8018-26fa6a577ba4'

// Set Devops Service Principal App Id

param servicePrincipalAppId string = '5c1aaf0e-670c-4f89-bbfd-70966a423822'
@secure()
param secret string

// Required DNS Options: Default deployment requires that only one of these options be set to true:

param enableFirewall bool = false // deploys Azure Firewall with DNS Proxy and Policy into each Core
param enableDNSResolver bool = false // deploys DNS Private Resolver into each Core

// Additional Options:

param enableBastion bool = false // deploys Azure Bastion into each Core - see Bastion options below
param enableVPNGateway bool = false // deploys VPN Gateway into each Regional VWAN Hub
param enableExpressRouteGateway bool = false // future rev - deploys Express Route Gateway into each Regional VWAN Hub
param enableDomainControllers bool = false // deploys VM availability set for DCs in each Regional Core
param enableRecoveryServiceVault bool = false // deploys Recovery Service Vault in each Regional Core
param enableSpokeSubnets bool = true // deploys pre-configured spoke subnets above nnn.nnn.250.nnn
param enableAzureVirtualDesktop bool = false // deploys AVD on its own Spoke
param enableAppGateway bool = false // future rev
param enableFrontdoor bool = false // future rev
param enableTrafficManager bool = false // future rev
param enableAKS1 bool = false // future rev
param enableAKS2 bool = false // future rev
param enableDataBricks1 bool = false // future rev
param enableDataBricks2 bool = false // future rev

// Set VWAN Subscriptions

param vwanSubscriptionId string = 'd580b55c-b966-4206-b5a1-c636edc3e440' // Virtual WAN

// Set VWAN Hub Subscriptions

param vwanHubSubscriptionIds array = [
  'd580b55c-b966-4206-b5a1-c636edc3e440' // Virtual WAN Primary Hub
  'f00685ca-68fd-4a05-a1aa-10926c8c9e9c' // Virtual WAN Secondary Hub
]

// Set Core Subscriptions

param coreSubscriptionIds array = [
  'd580b55c-b966-4206-b5a1-c636edc3e440' // Primary Core
  'f00685ca-68fd-4a05-a1aa-10926c8c9e9c' // Secondary Core [BCDR]
]

// Set Progressive Environment Subscriptions [Dev>Test>Stage>UAT>Prod]

param spokeSubscriptionIds array = [
  '48a3be76-0205-42c4-96ee-ac26c9155a11' // Dev Spoke
  '95c3b56a-3480-40a4-976a-45a492308ae0' // Test Spoke
  '0353c552-328a-47f9-b5f5-658391fb8b30' // Stage Spoke
  'eb3d4283-b6e8-47e0-a87d-4117b5356bdb' // UAT/QA Spoke
  '81eb8685-cab5-4256-bd59-4d359479ad74' // Prod Spoke
]

// Set Progressive Environment Subscriptions [BCDR] [Dev>Test>Stage>UAT>Prod]

param spokeSubscriptionIdsBCDR array = [
  'f00685ca-68fd-4a05-a1aa-10926c8c9e9c' // Prod Spoke [BCDR]
]

// Set Primary and Secondary [BCDR] Regions

param primaryRegionName string = 'centralus'
param secondaryRegionName string = 'eastus2'

// Locations Arrays

param vwanLocation string = primaryRegionName
param vwanHubLocations array = [
  '${primaryRegionName}'
  '${secondaryRegionName}'
]
param coreLocations array = [
  '${primaryRegionName}'
  '${secondaryRegionName}'
]
param spokeLocations array = [
  '${primaryRegionName}'
]
param spokeLocationsBCDR array = [
  '${secondaryRegionName}'
]

// CAF Naming and Defaults / Build CAF Naming Standard Prefix

param vwanCAFPrefix string = 'ohccus' // Core
param vwanHubCAFPrefixes array = [
  'ohcorcus' // Core
  'ohcoreus2' // Core [BCDR] 
]
param coreCAFPrefixes array = [
  'ohcorcus' // Core
  'ohcoreus2' // Core [BCDR]
]

param spokeCAFPrefixesBCDR array = [
  'ohprdeus2' // Prod [BCDR]
]

// Default Tag Set

param tags object = {
  Billing: 'IT'
  Ownership: 'IT'
  Diagnostics: 'true'
}

// Virtual Network / CIDRPrefixes / First Two Octets Only

param CIDRPrefixVWAN string = '10.0'
param CIDRPrefixCore string = '10.1'
param CIDRPrefixDev string = '10.2'
param CIDRPrefixTest string = '10.3'
param CIDRPrefixStage string = '10.4'
param CIDRPrefixUAT string = '10.5'
param CIDRPrefixProd string = '10.6'
param CIDRPrefixCoreBCDR string = '10.10'
param CIDRPrefixProdBCDR string = '10.11'

// Address Prefix Arrays

param coreCIDRPrefixes array = [
  '${CIDRPrefixCore}'
  '${CIDRPrefixCoreBCDR}'
]
param spokeCIDRPrefixes array = [
  '${CIDRPrefixDev}'
  '${CIDRPrefixTest}'
  '${CIDRPrefixStage}'
  '${CIDRPrefixUAT}'
  '${CIDRPrefixProd}'
]
param spokeCIDRPrefixesBCDR array = [
  '${CIDRPrefixProdBCDR}'
]

// Virtual Network / Address Spaces

param addressSpaceDev string = '${CIDRPrefixDev}.0.0/16'
param addressSpaceTest string = '${CIDRPrefixTest}.0.0/16'
param addressSpaceStage string = '${CIDRPrefixStage}.0.0/16'
param addressSpaceUAT string = '${CIDRPrefixUAT}.0.0/16'
param addressSpaceCore string = '${CIDRPrefixCore}.0.0/16'
param addressSpaceProd string = '${CIDRPrefixProd}.0.0/16'
param addressSpaceCoreBCDR string = '${CIDRPrefixCoreBCDR}.0.0/16'
param addressSpaceProdBCDR string = '${CIDRPrefixProdBCDR}.0.0/16'
param addressSpaceHubPrimary string = '${CIDRPrefixVWAN}.0.0/23'
param addressSpaceHubSecondary string = '${CIDRPrefixVWAN}.2.0/23'
// param addressSpaceHubTertiary string = '${CIDRPrefixVWAN}.4.0/23'
// param addressSpaceHubquaternary string = '${CIDRPrefixVWAN}.6.0/23'

// Address Spaces

param vwanHubAddressSpaces array = [
  addressSpaceHubPrimary
  addressSpaceHubSecondary
  // addressSpaceHubTertiary
  // addressSpaceHubQuaternary
]
param coreAddressSpaces array = [
  '${addressSpaceCore}'
  '${addressSpaceCoreBCDR}'
]
param spokeAddressSpaces array = [
  '${addressSpaceDev}'
  '${addressSpaceTest}'
  '${addressSpaceStage}'
  '${addressSpaceUAT}'
  '${addressSpaceProd}'
]
param spokeAddressSpacesBCDR array = [
  '${addressSpaceProdBCDR}'
]

// Azure Firewall

@allowed([
  'Premium'
  'Standard'
])
param firewallTier string = 'Standard'
param numberOfPublicIPs int = 1

// Azure DNS Servers Possibilities

param azureDNSPrivateResolver string = '${CIDRPrefixCore}.1.4' // DNS Private Resolver IP
param azureDNSPrivateResolverBCDR string = '${CIDRPrefixCore}.1.4' // DNS Private Resolver IP
param azureFirewallDNSProxy string = '${CIDRPrefixVWAN}.64.4' // Azure Firewall Proxy IP
param azureFirewallDNSProxyBCDR string = '${CIDRPrefixVWAN}.64.4' // Azure Firewall Proxy IP
param onPremDNSServer string = '${CIDRPrefixCore}.3.4' // Preferred: IP of the Domain Controller in each Core / Edit if needed

// DNS Server Arrays

param dnsFirewallProxy array = [
  azureFirewallDNSProxy // Azure Firewall Proxy IP
  onPremDNSServer // Core Domain Controller IP
]

param dnsPrivateResolver array = [
  azureDNSPrivateResolver // DNS Private Resolver IP
  onPremDNSServer // Core Domain Controller IP
]

// Virtual WAN Options

@allowed([
  'Standard'
  'Basic'
])
param vwanSKUType string = 'Standard'

@allowed([
  true
  false
])
param allowBranchToBranchTraffic bool = true

@allowed([
  true
  false
])
param allowVnetToVnetTraffic bool = true

@allowed([
  'ExpressRoute'
  'None'
  'VpnGateway'
])
param preferredRoutingGateway string = 'None'

@allowed([
  'ASPath'
  'ExpressRoute'
  'VpnGateway'
])
param hubRoutingPreference string = 'VpnGateway'

// VPN Gateway

@allowed([
  1
])
param vpnGatewayScaleUnit int = 1

@allowed([
  65515
  65517
  65518
  65519
  65520
])
param bgpSettings int = 65515

@allowed([
  true
  false
])
param disableVpnEncryption bool = false

// VPN Gateway / Site-to-Site Connection

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

// Azure Bastion Host / Adjust to meet Client Security requirements

@allowed([
  'Dynamic'
  'Static'
])
param privateIPAllocationMethod string = 'Dynamic'
param disableCopyPaste bool = false
param enableFileCopy bool = true
param enableIpConnect bool = true
param enableShareableLink bool = true
param enableTunneling bool = true
param scaleUnits int = 2

// Call Core Deployment(s) Module

module networkResourcesCore 'modules/subNetworkCore.bicep' = [for i in range(0, length(coreSubscriptionIds)): {
  scope: subscription(coreSubscriptionIds[i])
  name: 'main.bicep.networkResourceCore'
  params: {
    // Azure Bastion Host
    enableBastion: enableBastion
    privateIPAllocationMethod: privateIPAllocationMethod
    enableShareableLink: enableShareableLink
    disableCopyPaste: disableCopyPaste
    enableIpConnect: enableIpConnect
    enableTunneling: enableTunneling
    enableFileCopy: enableFileCopy
    scaleUnits: scaleUnits
    // Virtual Machines / Domain Controller
    enableDomainControllers: enableDomainControllers
    numberOfDcInstances: numberOfDcInstances
    domainToJoin: domainToJoin
    vmDiskType: vmDiskType
    OSVersion: OSVersion
    ouPath: ouPath
    vmSize: vmSize
    // Various Globals
    tenantId: tenantId
    servicePrincipalAppId: servicePrincipalAppId
    primaryRegionName: primaryRegionName
    secondaryRegionName: secondaryRegionName
    secret: secret
    // Virtual Networks
    enableSpokeSubnets: enableSpokeSubnets
    // VWAN Arrays
    vwanHubSubscriptionIds: vwanHubSubscriptionIds
    vwanHubAddressSpaces: vwanHubAddressSpaces
    vwanHubCAFPrefixes: vwanHubCAFPrefixes
    vwanHubLocations: vwanHubLocations
    vwanLocation: vwanLocation
    vwanCAFPrefix: vwanCAFPrefix
    // Core Arrays
    coreSubscriptionIds: coreSubscriptionIds[i]
    coreAddressSpaces: coreAddressSpaces[i]
    coreCIDRPrefixes: coreCIDRPrefixes[i]
    coreCAFPrefixes: coreCAFPrefixes[i]
    coreLocations: coreLocations[i]
    // Spoke Arrays
    spokeSubscriptionIds: spokeSubscriptionIds
    spokeAddressSpaces: spokeAddressSpaces
    spokeCIDRPrefixes: spokeCIDRPrefixes
    spokeCAFPrefixes: spokeCAFPrefixes
    spokeLocations: spokeLocations
    // Spoke Arrays BCDR
    spokeSubscriptionIdsBCDR: spokeSubscriptionIdsBCDR
    spokeAddressSpacesBCDR: spokeAddressSpacesBCDR
    spokeCIDRPrefixesBCDR: spokeCIDRPrefixesBCDR
    spokeCAFPrefixesBCDR: spokeCAFPrefixesBCDR
    spokeLocationsBCDR: spokeLocationsBCDR
    // Azure Firewall
    enableFirewall: enableFirewall
    numberOfPublicIPs: numberOfPublicIPs
    firewallTier: firewallTier
    // DNS Servers
    enableDNSResolver: enableDNSResolver
    onPremDNSServer: onPremDNSServer
    dnsFirewallProxy: dnsFirewallProxy
    dnsPrivateResolver: dnsPrivateResolver
    // Virtual WAN
    vwanSKUType: vwanSKUType
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    preferredRoutingGateway: preferredRoutingGateway
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    hubRoutingPreference: hubRoutingPreference
    // VPN Gateway
    enableVPNGateway: enableVPNGateway
    bgpSettings: bgpSettings
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    // Recovery Service Vault
    enableRecoveryServiceVault: enableRecoveryServiceVault
    // Tags
    tags: tags
  }
  dependsOn: [

  ]
}]
