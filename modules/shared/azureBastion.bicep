param bastionName string
param location string
param tags object
param scaleUnits int
param publicIpBastion string
param bastionSubnet string

resource bastionhosts 'Microsoft.Network/bastionHosts@2021-08-01' = {
  name: bastionName
  location: location
  tags: tags
  sku: {
    name: 'string'
  }
  properties: {
    disableCopyPaste: false
    dnsName: bastionName
    enableFileCopy: true
    enableIpConnect: true
    enableShareableLink: true
    enableTunneling: true
    ipConfigurations: [
      {
        id: 'string'
        name: 'string'
        properties: {
          privateIPAllocationMethod: 'string'
          publicIPAddress: {
            id: publicIpBastion
          }
          subnet: {
            id: bastionSubnet
          }
        }
      }
    ]
    scaleUnits: scaleUnits
  }
}
