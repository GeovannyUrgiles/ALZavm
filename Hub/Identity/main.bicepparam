using 'br/public:avm/res/compute/virtual-machine:<version>'

// Required parameters
param adminUsername = 'localAdminUser'
param imageReference = {
  offer: '0001-com-ubuntu-server-jammy'
  publisher: 'Canonical'
  sku: '22_04-lts-gen2'
  version: 'latest'
}
param name = 'cvmlinatmg'
param nicConfigurations = [
  {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        pipConfiguration: {
          publicIpNameSuffix: '-pip-01'
          zones: [
            1
            2
            3
          ]
        }
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    nicSuffix: '-nic-01'
  }
]
param osDisk = {
  diskSizeGB: 128
  managedDisk: {
    storageAccountType: 'Premium_LRS'
  }
}
param osType = 'Linux'
param vmSize = 'Standard_DS2_v2'
param zone = 0
// Non-required parameters
param configurationProfile = '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
param disablePasswordAuthentication = true
param location = '<location>'
param publicKeys = [
  {
    keyData: '<keyData>'
    path: '/home/localAdminUser/.ssh/authorized_keys'
  }
]
