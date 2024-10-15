
param tags object
param disableCopyPaste bool
param enableFileCopy bool
param enableIpConnect bool
param enableShareableLink bool
param enableTunneling bool
param privateIPAllocationMethod string
param coreCAFPrefixes string
param location string
param scaleUnits int
param subnet string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: '${coreCAFPrefixes}bhpip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
  dependsOn: [
  ]
}

resource azureBastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name: '${coreCAFPrefixes}bh'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    disableCopyPaste: disableCopyPaste
    dnsName: '${coreCAFPrefixes}bh'
    enableFileCopy: enableFileCopy
    enableIpConnect: enableIpConnect
    enableShareableLink: enableShareableLink
    enableTunneling: enableTunneling
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          publicIPAddress: {
            id: publicIPAddress.id
          }
          subnet: {
            id: subnet
          }
        }
      }
    ]
    scaleUnits: scaleUnits
  }
  dependsOn: [

  ]
}
