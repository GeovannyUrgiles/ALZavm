param location string = 'eastus'

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.7.0' = {
  name: 'virtualMachineDeployment'
  params: {
    // Required parameters
    adminUsername: 'localAdminUser'
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    name: 'cvmlinatmg'
    nicConfigurations: [
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
    osDisk: {
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_DS2_v2'
    zone: 0
    // Non-required parameters
    configurationProfile: '/providers/Microsoft.Automanage/bestPractices/AzureBestPracticesProduction'
    disablePasswordAuthentication: true
    location: '<location>'
    publicKeys: [
      {
        keyData: '<keyData>'
        path: '/home/localAdminUser/.ssh/authorized_keys'
      }
    ]
  }
}
