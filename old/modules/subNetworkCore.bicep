targetScope = 'subscription'

// Hub Arrays
param vwanCAFPrefix string
param vwanLocation string

param vwanHubSubscriptionIds array

param vwanHubAddressSpaces array
param vwanHubCAFPrefixes array
param vwanHubLocations array

// Core Arrays
param coreSubscriptionIds string
param coreAddressSpaces string
param coreCIDRPrefixes string
param coreCAFPrefixes string
param coreLocations string
// Spoke Arrays
param enableSpokeSubnets bool
param spokeSubscriptionIds array
param spokeAddressSpaces array
param spokeCIDRPrefixes array
param spokeCAFPrefixes array
param spokeLocations array
// VPN Gateway Site-to-Site
param enableVPNGateway bool
param disableVpnEncryption bool
param bgpSettings int
param vpnGatewayScaleUnit int
// Virtual WAN
param vwanSKUType string
param allowVnetToVnetTraffic bool
param allowBranchToBranchTraffic bool
// Virtual WAN Hub
param preferredRoutingGateway string
param hubRoutingPreference string
// BCDR Spoke Arrays
param spokeSubscriptionIdsBCDR array
param spokeAddressSpacesBCDR array
param spokeCIDRPrefixesBCDR array
param spokeCAFPrefixesBCDR array
param spokeLocationsBCDR array
// Azure DNS 
param enableDNSResolver bool
param onPremDNSServer string
param dnsFirewallProxy array
param dnsPrivateResolver array
// Globals
// param CIDRPrefixVWAN string
param tenantId string
param servicePrincipalAppId string
@secure()
param secret string
param primaryRegionName string
param secondaryRegionName string
// Recovery Service Vaults
param enableRecoveryServiceVault bool
// Azure Firewall
param enableFirewall bool
param firewallTier string
param numberOfPublicIPs int
// Tags & Location
param tags object
// Virtual Machines / Domain Controller
param enableDomainControllers bool
param domainToJoin string
param ouPath string
param numberOfDcInstances int
param vmDiskType string
param vmSize string
param OSVersion string
// Azure Bastion Host
param enableBastion bool
param disableCopyPaste bool
param enableFileCopy bool
param enableIpConnect bool
param enableShareableLink bool
param enableTunneling bool
param privateIPAllocationMethod string
param scaleUnits int

// Virtual Network / Privatelink DNS Zones

param privatelinkDnsZoneNames array = [// Index:
  'pbidedicated.windows.net' // 01
  'botplinks.botframework.com' // 02
  'bottoken.botframework.com' // 03
  'privatelinks.aznbcontent.net' // 04
  'privatelinks.notebooks.azure.net' // 05
  'privatelink.adf.azure.com' // 06
  'privatelink.azure-automation.net' // 07
  'privatelink.azurecr.io' // 08
  'privatelink.azurewebsites.net' // 09
  'privatelink.azurestaticapps.net' // 11
  'privatelink.analysis.windows.net' // 12
  'privatelink.azurehdinsight.net' // 13
  'privatelink.azure-api.net' // 14
  'privatelink.azconfig.io' // 15
  'privatelink.azure-devices.net' // 16
  'privatelink.azuresynapse.net' // 17
  'privatelink.agentsvc.azure-automation.net' // 18
  'privatelink.batch.azure.com' // 19
  'privatelink.blob.core.windows.net' // 20
  'privatelink.cassandra.cosmos.azure.com' // 21
  'privatelink.cognitiveservices.azure.com' // 22
  'privatelink.database.windows.net' // 23
  'privatelink.datafactory.azure.net' // 24
  'privatelink.dev.azuresynapse.net' // 25
  'privatelink.developer.azure-api.net' // 26
  'privatelink.dfs.core.windows.net' // 27
  'privatelink.digitaltwins.azure.net' // 28
  'privatelink.documents.azure.com' // 29
  'privatelink.eventgrid.azure.net' // 30
  'privatelink.file.core.windows.net' // 31
  'privatelink.guestconfiguration.azure.com' // 32
  'privatelink.his.arc.azure.com' // 33
  'privatelink.monitor.azure.com' // 34
  'privatelink.mongo.cosmos.azure.com' // 35
  'privatelink.mysql.database.azure.com' // 36
  'privatelink.mariadb.database.azure.com' // 37
  'privatelink.managedhsm.azure.net' // 38
  'privatelink.media.azure.net' // 40
  'privatelink.ods.opinsights.azure.com' // 42
  'privatelink.oms.opinsights.azure.com' // 43
  'privatelink.postgres.database.azure.com' // 44
  'privatelink.purview.azure.com' // 45
  'privatelink.purviewstudio.azure.com' // 46
  'privatelink.prod.migration.windowsazure.com' // 47
  'privatelink.pbidedicated.windows.net' // 48
  'privatelink.queue.core.windows.net' // 50
  'privatelink.redis.cache.windows.net' // 51
  'privatelink.redisenterprise.cache.azure.net' // 52
  'privatelink.search.windows.net' // 54
  'privatelink.service.signalr.net' // 55
  'privatelink.servicebus.windows.net' // 56
  'privatelink.sql.azuresynapse.net' // 57
  'privatelink.table.core.windows.net' // 58
  'privatelink.table.cosmos.azure.com' // 59
  'privatelink.tip1.powerquery.microsoft.com' // 60
  'privatelink.vaultcore.azure.net' // 61
  'privatelink.web.core.windows.net' // 62
  'privatelink.gremlin.cosmos.azure.com' // 63
]

// DNS Private Resolver Subnet Names [shouldn't change]

param DNSInboundSubnetName string = 'AzureDNSInboundSubnet'
param DNSOutboundSubnetName string = 'AzureDNSOutboundSubnet'

// Network Security Group Defaults

param nsgRules array = []

// Subnets / Core [Hub] Networks

param subnetsCore array = [
  // Azure Bastion Subnet
  {
    name: 'AzureBastionSubnet'
    subnetPrefix: '${coreCIDRPrefixes}.0.0/26'
  }
  // Azure DNS Resolver / Inbound Subnet
  {
    name: DNSInboundSubnetName
    subnetPrefix: '${coreCIDRPrefixes}.1.0/24'
  }
  // Azure DNS Resolver / Outbound Subnet
  {
    name: DNSOutboundSubnetName
    subnetPrefix: '${coreCIDRPrefixes}.2.0/24'
  }
  {
    name: 'ActiveDirectorySubnet'
    subnetPrefix: '${coreCIDRPrefixes}.3.0/24'
  }
  // Azure PrivateEndpoint Subnet
  {
    name: 'AzurePrivateEndpointSubnet'
    subnetPrefix: '${coreCIDRPrefixes}.254.0/23'
  }
]

// Resource Groups

resource resourceGroupNetworkCore 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${coreCAFPrefixes}networkrg'
  location: coreLocations
  tags: tags
  dependsOn: []
}

// Virtual WAN

module virtualWan 'network/virtualWan.bicep' = if (coreLocations == primaryRegionName) {
  scope: resourceGroupNetworkCore
  name: 'subVirtualWan.bicep.virtualWan'
  params: {
    enableFirewall: enableFirewall
    firewallTier: firewallTier
    numberOfPublicIPs: numberOfPublicIPs
    onPremDNSServer: onPremDNSServer
    bgpSettings: bgpSettings
    enableVPNGateway: enableVPNGateway
    vpnGatewayScaleUnit: vpnGatewayScaleUnit
    vwanHubAddressSpaces: vwanHubAddressSpaces
    vwanHubCAFPrefixes: vwanHubCAFPrefixes
    vwanHubLocations: vwanHubLocations
    vwanHubSubscriptionIds: vwanHubSubscriptionIds
    hubRoutingPreference: hubRoutingPreference
    preferredRoutingGateway: preferredRoutingGateway
    vwanCAFPrefixes: vwanCAFPrefix
    location: vwanLocation
    vwanSKUType: vwanSKUType
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    tags: tags
  }
}

// Virtual Network Core and Core DR

module virtualNetworkCore 'network/virtualNetworkCore.bicep' = {
  scope: resourceGroupNetworkCore
  name: 'subNetworkCore.bicep.virtualNetworkCore'
  params: {
    addressSpaces: coreAddressSpaces
    coreCAFPrefixes: coreCAFPrefixes
    location: coreLocations
    dnsServers: ((enableFirewall == true) ? dnsFirewallProxy : dnsPrivateResolver)
    subnets: subnetsCore
    tags: tags
  }
  dependsOn: []
}

// Private DNS Zone Creation

module privateDnsZones 'network/azureDNSPrivateZones.bicep' = {
  scope: resourceGroupNetworkCore
  name: 'subNetworkCore.bicep.privateDnsZones'
  params: {
    tags: tags
    privateDnsZoneNames: privatelinkDnsZoneNames
  }
  dependsOn: [
    virtualNetworkCore
  ]
}

// Private DNS Zone Network Links

module privateDnsLinks 'network/azureDNSPrivateLinks.bicep' = {
  scope: resourceGroupNetworkCore
  name: 'subNetworkCore.bicep.privateDnsLinks'
  params: {
    virtualNetworkId: virtualNetworkCore.outputs.virtualNetworkIdCore
    virtualNetworkName: virtualNetworkCore.outputs.virtualNetworkNameCore
    privatelinkDnsZoneNames: privatelinkDnsZoneNames
  }
  dependsOn: [
    privateDnsZones
  ]
}

// DNS Private Resolver / **Preview - check regional availability first

module dnsResolver 'network/azureDNSPrivateResolver.bicep' = if (enableDNSResolver == true) {
  scope: resourceGroupNetworkCore
  name: 'subNetworkCore.bicep.DNSResolver'
  params: {
    coreCAFPrefixes: coreCAFPrefixes
    AzureDNSInboundSubnet: DNSInboundSubnetName
    AzureDNSOutboundSubnet: DNSOutboundSubnetName
    virtualNetworkId: virtualNetworkCore.outputs.virtualNetworkIdCore
    location: coreLocations
  }
  dependsOn: [
    virtualNetworkCore
  ]
}

// Virtual Machines / Domain Controllers

module domainControllers 'virtualmachines/virtualMachineDomainController.bicep' = if (enableDomainControllers == true) {
  scope: resourceGroupNetworkCore
  name: 'subNetworkCore.bicep.domainControllers'
  params: {
    OSVersion: OSVersion
    domainToJoin: domainToJoin
    ouPath: ouPath
    // administratorAccountUserName: ''
    // administratorAccountPassword: ''
    subnetId: virtualNetworkCore.outputs.activeDirectorySubIdCore
    coreCAFPrefixes: coreCAFPrefixes
    numberOfDcInstances: numberOfDcInstances
    vmDiskType: vmDiskType
    vmSize: vmSize
    location: coreLocations
  }
  dependsOn: [
    virtualNetworkCore
  ]
}

// Azure Bastion Host

module azureBastionHost 'network/azureBastion.bicep' = if (enableBastion == true) {
  scope: resourceGroupNetworkCore
  name: 'subNetworkCore.bicep.azureBastion'
  params: {
    coreCAFPrefixes: coreCAFPrefixes
    disableCopyPaste: disableCopyPaste
    enableIpConnect: enableIpConnect
    enableFileCopy: enableFileCopy
    scaleUnits: scaleUnits
    enableShareableLink: enableShareableLink
    tags: tags
    subnet: virtualNetworkCore.outputs.bastionSubIdCore
    privateIPAllocationMethod: privateIPAllocationMethod
    enableTunneling: enableTunneling
    location: coreLocations
  }
  dependsOn: [
    virtualNetworkCore
  ]
}

// Build Dynamic Core Subnet Id Outputs

module dynamicCoreIds 'network/dynamicSubnets.bicep' = {
  scope: resourceGroupNetworkCore
  name: 'dynamicSubnets.bicep.dynamicCoreIds'
  params: {
    secret: secret
    tenantId: tenantId
    subscriptionId: coreSubscriptionIds
    servicePrincipalAppId: servicePrincipalAppId
    location: coreLocations
    virtualNetworkName: virtualNetworkCore.outputs.virtualNetworkNameCore
  }
  dependsOn: [
    virtualNetworkCore
  ]
}

// Virtual Network Connections initiated from VWAN

module coreHubToCore 'network/virtualWanHubPeering.bicep' = {
  scope: resourceGroup(vwanHubSubscriptionIds[0], '${vwanHubCAFPrefixes[0]}networkrg')
  name: '${coreCAFPrefixes}hub-to-${coreCAFPrefixes}vnet'
  params: {
    coreSubscriptionIds: coreSubscriptionIds
    virtualNetworkSpokeName: virtualNetworkCore.outputs.virtualNetworkNameCore
    virtualWanHubName: '${coreCAFPrefixes}hub'
    virtualNetworkSpokeId: virtualNetworkCore.outputs.virtualNetworkIdCore
    location: coreLocations
  }
  dependsOn: [
    virtualNetworkCore
  ]
}

// Deploy Common Subscription-wide Resources

module sharedResources 'subCommonResources.bicep' = {
  scope: subscription(coreSubscriptionIds)
  name: 'subNetworkSpoke.bicep.sharedResources'
  params: {
    pepSubnetId: dynamicCoreIds.outputs.azurePrivateEndpointSubnetId
    privateDNSZoneNameAutomation: privateDnsZones.outputs.privateDnsZoneId_azure_automation
    privateDNSZoneNameKeyVault: privateDnsZones.outputs.privateDnsZoneId_vaultcore
    privateDNSZoneNameStorageBlob: privateDnsZones.outputs.privateDnsZoneId_blob_core
    privateDNSZoneNameStorageFile: privateDnsZones.outputs.privateDnsZoneId_file_core
    privateDNSZoneNameStorageTable: privateDnsZones.outputs.privateDnsZoneId_table_core
    privateDNSZoneNameStorageQueue: privateDnsZones.outputs.privateDnsZoneId_queue_core
    spokeCAFPrefixes: coreCAFPrefixes
    spokeCIDRPrefixes: coreCIDRPrefixes
    enableRecoveryServiceVault: enableRecoveryServiceVault
    location: coreLocations
    tenantId: tenantId
    tags: tags
  }
  dependsOn: [
    virtualNetworkCore
    dynamicCoreIds
  ]
}

// Build Primary Spoke Development Networks

module networkSpoke 'subNetworkSpoke.bicep' = [for i in range(0, length(spokeSubscriptionIds)) : if (coreLocations == primaryRegionName) {
  scope: subscription(spokeSubscriptionIds[i])
  name: 'subNetworkCore.bicep.networkSpoke'
  params: {
    vwanHubCAFPrefixes: vwanHubCAFPrefixes
    vwanHubSubscriptionIds: vwanHubSubscriptionIds
    dnsFirewallProxy: dnsFirewallProxy
    dnsPrivateResolver: dnsPrivateResolver
    enableFirewall: enableFirewall
    enableSpokeSubnets: enableSpokeSubnets
    servicePrincipalAppId: servicePrincipalAppId
    secret: secret
    coreSubscriptionIds: coreSubscriptionIds
    privateDNSZoneNameAutomation: privateDnsZones.outputs.privateDnsZoneId_azure_automation
    privateDNSZoneNameKeyVault: privateDnsZones.outputs.privateDnsZoneId_vaultcore
    privateDNSZoneNameStorageBlob: privateDnsZones.outputs.privateDnsZoneId_blob_core
    privateDNSZoneNameStorageFile: privateDnsZones.outputs.privateDnsZoneId_file_core
    privateDNSZoneNameStorageTable: privateDnsZones.outputs.privateDnsZoneId_table_core
    privateDNSZoneNameStorageQueue: privateDnsZones.outputs.privateDnsZoneId_queue_core
    spokeSubscriptionIds: spokeSubscriptionIds[i]
    spokeAddressSpaces: spokeAddressSpaces[i]
    spokeCIDRPrefixes: spokeCIDRPrefixes[i]
    spokeCAFPrefixes: spokeCAFPrefixes[i]
    location: spokeLocations[0]
    tenantId: tenantId
    nsgRules: nsgRules
    tags: tags
  }
  dependsOn: [
    virtualNetworkCore
  ]
}]

// Build Secondary Spoke Development Networks

module networkSpokeBCDR 'subNetworkSpokeBCDR.bicep' = [for i in range(0, length(spokeSubscriptionIdsBCDR)): if (coreLocations == secondaryRegionName) {
  scope: subscription(spokeSubscriptionIdsBCDR[i])
  name: 'subNetworkCoreBCDR.bicep.networkSpokeBCDR'
  params: {
    vwanHubCAFPrefixes: vwanHubCAFPrefixes
    vwanHubSubscriptionIds: vwanHubSubscriptionIds
    enableFirewall: enableFirewall
    // DNS Arrays    
    dnsFirewallProxy: dnsFirewallProxy
    dnsPrivateResolver: dnsPrivateResolver
    enableSpokeSubnets: enableSpokeSubnets
    servicePrincipalAppId: servicePrincipalAppId
    secret: secret
    coreSubscriptionIds: coreSubscriptionIds
    // Private DNS Zone Groups
    privateDNSZoneNameAutomation: privateDnsZones.outputs.privateDnsZoneId_azure_automation
    privateDNSZoneNameKeyVault: privateDnsZones.outputs.privateDnsZoneId_vaultcore
    privateDNSZoneNameStorageBlob: privateDnsZones.outputs.privateDnsZoneId_blob_core
    privateDNSZoneNameStorageFile: privateDnsZones.outputs.privateDnsZoneId_file_core
    privateDNSZoneNameStorageTable: privateDnsZones.outputs.privateDnsZoneId_table_core
    privateDNSZoneNameStorageQueue: privateDnsZones.outputs.privateDnsZoneId_queue_core
    spokeSubscriptionIdsBCDR: spokeSubscriptionIdsBCDR[i]
    spokeAddressSpacesBCDR: spokeAddressSpacesBCDR[i]
    spokeCIDRPrefixesBCDR: spokeCIDRPrefixesBCDR[i]
    spokeCAFPrefixesBCDR: spokeCAFPrefixesBCDR[i]
    location: spokeLocationsBCDR[0]
    tenantId: tenantId
    nsgRules: nsgRules
    tags: tags
  }
  dependsOn: [
    virtualNetworkCore
  ]
}]
